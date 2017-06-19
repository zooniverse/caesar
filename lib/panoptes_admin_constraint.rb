class PanoptesAdminConstraint
  def matches?(request)
    credentials = request.session[:credentials]
    user = CurrentUser.new(credentials)
    user.logged_in? && user.admin?
  rescue JWT::ExpiredSignature
    false
  end
end
