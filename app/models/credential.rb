class Credential < ApplicationRecord
  Type = GraphQL::ObjectType.define do
    name "Credential"
    field :isLoggedIn, !types.Boolean, property: :logged_in?
    field :isAdmin, !types.Boolean, property: :admin?
  end

  before_create :set_expires_at

  def logged_in?
    jwt_payload["login"].present?
  rescue JWT::ExpiredSignature
    false
  end

  def login
    jwt_payload.fetch("login")
  end

  def admin?
    return true if Rails.env.development?
    jwt_payload.fetch("admin", false)
  rescue JWT::ExpiredSignature
    false
  end

  def ok?
    jwt_payload.present? && !expired?
  end

  def expired?
    expires_at < Time.zone.now
  end

  def fetch_accessible_projects
    client.panoptes.paginate("/projects", current_user_roles: ['owner', 'collaborator'])
  end

  def accessible_workflow?(id)
    response = client.panoptes.get("/workflows/#{id}")
    workflow_hash = response["workflows"][0]
    project_id = workflow_hash["links"]["project"].to_i

    if project_ids.include?(project_id)
      workflow_hash
    end
  rescue Panoptes::Client::ResourceNotFound
    nil
  end

  private

  def jwt_payload
    if token
      @jwt_payload ||= client.current_user
    else
      @jwt_payload ||= {}
    end
  end

  def client
    @client ||= Panoptes::Client.new(env: panoptes_client_env, auth: {token: token})
  end

  def panoptes_client_env
    case Rails.env.to_s
    when "production"
      "production"
    when "test"
      "test"
    else
      "staging"
    end
  end

  def set_expires_at
    unless expires_at.present?
      payload, _ = JWT.decode token, client.jwt_signing_public_key, algorithm: 'RS512'
      self.expires_at ||= Time.at(payload.fetch("exp"))
    end
  end
end
