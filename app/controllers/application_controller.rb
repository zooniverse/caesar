class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Basic
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include Pundit

  protect_from_forgery with: :reset_session

  helper_method :credential

  before_action :authenticate!

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  respond_to :html, :json

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def authenticate!
    handle_unauthenticated_request("Login required.") unless authenticated?
  rescue JWT::ExpiredSignature
    handle_unauthenticated_request("Session expired. Please log in again.")
  end

  def authenticated?
    credential.ok?
  end

  def credential
    return OpenStruct.new(login: 'dev', ok?: true, logged_in?: true, expired?: false, admin?: true) if Rails.env.development?

    token = session_token || bearer_token

    @credential ||= if token
                      Credential.find_or_create_by(token: token) do |credential|
                        if session[:credentials]
                          credential.refresh = session[:credentials]["refresh_token"]
                          credential.expires_at = Time.at(session[:credentials]["expires_at"])
                        end

                        credential.project_ids = credential.fetch_accessible_projects["projects"].map{ |prj| prj["id"] }
                      end
                    else
                      Credential.new expires_at: 2.minutes.from_now
                    end
  end

  # Alias for Pundit
  def current_user
    credential
  end

  def session_token
    session[:credentials] && session[:credentials]["token"]
  end

  def bearer_token
    return unless request.headers['Authorization']

    request.headers['Authorization'].match(/\ABearer (?<token>.*)\Z/)["token"]
  end

  def record_not_found
    head 404
  end

  def handle_unauthenticated_request(message)
    respond_to do |format|
      format.html do
        reset_session
        redirect_to session_path, alert: message
      end

      format.json do
        head :unauthorized
      end
    end
  end

end
