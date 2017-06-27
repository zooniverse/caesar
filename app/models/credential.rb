class Credential < ApplicationRecord
  def logged_in?
    jwt_payload["login"].present?
  end

  def login
    jwt_payload.fetch("login")
  end

  def admin?
    jwt_payload.fetch("admin", false)
  end

  def expired?
    expires_at < Time.utc.now
  end

  def fetch_accessible_projects
    client.panoptes.paginate("/projects", current_user_roles: ['owner', 'collaborator'])
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
end
