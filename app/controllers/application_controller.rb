class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Basic
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  protect_from_forgery with: :reset_session

  helper_method :current_user

  before_action :authorize!

  private

  def current_user
    @current_user ||= CurrentUser.new(session[:credentials])
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
