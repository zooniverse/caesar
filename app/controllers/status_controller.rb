class StatusController < ApplicationController
  skip_before_action :authenticate!

  def show
    skip_authorization
    @status = ApplicationStatus.new
    respond_with @status
  end
end
