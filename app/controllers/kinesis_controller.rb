class KinesisController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :require_http_basic_authentication

  def create
    kinesis_stream.receive(params.to_unsafe_h["_json"])
    head :no_content
  end

  private

  def require_http_basic_authentication
    if authenticate_with_http_basic { |user, pass| authenticate(user, pass)  }
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
      Rails.env.development? || Rails.env.test?
    end
  end

  def kinesis_stream
    KinesisStream.new
  end
end
