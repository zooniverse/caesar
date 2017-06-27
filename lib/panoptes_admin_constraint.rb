class PanoptesAdminConstraint
  def matches?(request)
    credentials = request.session[:credentials]
    return false unless credentials
    return false unless credentials["token"]

    user = Credential.new(token: credentials["token"])
    user.logged_in? && user.admin?
  rescue JWT::ExpiredSignature
    false
  end
end
