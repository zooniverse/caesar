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
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

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

  def record_not_found(exception)
    render json: {error: exception.message}, status: 404
  end

  def record_invalid(exception)
    render json: exception.record.errors, status: 422
  end

  def not_authorized
    head 401
  end

  def handle_unauthenticated_request(message)
    respond_to do |format|
      format.html do
        reset_session
        session[:return_to] = request.url
        redirect_to '/auth/zooniverse', alert: message
      end

      format.json do
        head :unauthorized
      end
    end
  end

end
