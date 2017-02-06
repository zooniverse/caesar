class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic
  include ActionController::HttpAuthentication::Basic::ControllerMethods
end
