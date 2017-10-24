class StatusController < ApplicationController
  def show
    skip_authorization
    @status = ApplicationStatus.new
    respond_with @status
  end
end
