class PanoptesAdminConstraint
  def matches?(request)
    return true if Rails.env.development?

    credentials = request.session[:credentials]
    return false unless credentials
    return false unless credentials["token"]

    user = Credential.new(token: credentials["token"])
    user.logged_in? && user.admin?
  rescue Panoptes::Client::AuthenticationExpired
    false
  end
end
