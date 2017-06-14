class PanoptesAdminConstraint
  def matches?(request)
    user = current_user(request.session)
    user.logged_in? && user.admin?
  end

  def panoptes_client(session)
    panoptes_client_env = case Rails.env.to_s
                          when "production"
                            "production"
                          else
                            "staging"
                          end

    @panoptes_client = Panoptes::Client.new(env: panoptes_client_env, auth: {token: session[:credentials]["token"]})
  end

  def current_user(session)
    if session[:credentials]
      CurrentUser.new(panoptes_client(session).current_user)
    else
      CurrentUser.new({})
    end
  end
end
