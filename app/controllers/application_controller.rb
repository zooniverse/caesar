class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Basic
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  protect_from_forgery with: :reset_session

  helper_method :current_user

  before_action :authorize!

  private

  def panoptes_client
    panoptes_client_env = case Rails.env.to_s
                          when "production"
                            "production"
                          else
                            "staging"
                          end

    @panoptes_client = Panoptes::Client.new(env: panoptes_client_env, auth: {token: session[:credentials]["token"]})
  end

  def current_user
    if session[:credentials]
      CurrentUser.new(panoptes_client.current_user)
    else
      CurrentUser.new({})
    end
  end

  def authorize!
    unless authorized?
      head :forbidden
    end
  rescue JWT::ExpiredSignature
    reset_session
    redirect_to session_path, alert: "Session expired"
  end

  def authorized?
    current_user.admin?
  end
end
