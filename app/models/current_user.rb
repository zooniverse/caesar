class CurrentUser
  attr_reader :attributes

  def initialize(credentials)
    @credentials = credentials
  end

  def logged_in?
    attributes["login"].present?
  end

  def login
    attributes.fetch("login")
  end

  def admin?
    attributes.fetch("admin", false)
  end

  private

  def attributes
    if @credentials
      @attributes ||= panoptes_client.current_user
    else
      @attributes ||= {}
    end
  end

  def panoptes_client
    @panoptes_client ||= Panoptes::Client.new(env: panoptes_client_env, auth: {token: @credentials["token"]})
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
