class SessionsController < ApplicationController
  def new
  end

  def create
    session[:credentials] = request.env["omniauth.auth"]["credentials"]
  end

  def destroy
    reset_session
    redirect_to action: :new
  end
end
