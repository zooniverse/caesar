require 'sidekiq/web'
unless Rails.env.test? || Rails.env.development?
  desired_username = ENV.fetch("SIDEKIQ_WEB_USERNAME")
  desired_password = ENV.fetch("SIDEKIQ_WEB_PASSWORD")

  Sidekiq::Web.use Rack::Auth::Basic do |given_username, given_password|
    given_username.present? && desired_username.present? &&
      given_password.present? && desired_password.present? &&
      given_username == desired_username &&
      given_password == desired_password
  end
end
