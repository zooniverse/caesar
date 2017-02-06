class KinesisController < ApplicationController
  before_action :require_http_basic_authentication

  def create
    kinesis_stream.receive(params["payload"])
    head :no_content
  end

  private

  def require_http_basic_authentication
    if !has_basic_credentials?(request)
      allow_unauthenticated_request?
    elsif authenticate_with_http_basic { |user, pass| authenticate(user, pass) }
      true
    else
      head :forbidden
    end
  end

  def authenticate(given_username, given_password)
    desired_username = Rails.application.secrets.kinesis["username"]
    desired_password = Rails.application.secrets.kinesis["password"]

    if desired_username.present? || desired_password.present?
      given_username == desired_username && given_password == desired_password
    else
      # If no credentials configured in dev/test, don't require authentication
      allow_unauthenticated_request?
    end
  end

  def allow_unauthenticated_request?
    Rails.env.development? || Rails.env.test?
  end

  def kinesis_stream
    KinesisStream.new
  end
end
