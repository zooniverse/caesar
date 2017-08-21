class SessionsController < ApplicationController
  skip_before_action :authenticate!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    if credential.expired?
      reset_session
    end
  end

  def create
    session[:credentials] = request.env["omniauth.auth"]["credentials"]
    redirect_to session_path, notice: "Logged in"
  end

  def destroy
    reset_session
    redirect_to session_path, notice: "Logged out"
  end
end
