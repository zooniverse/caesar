class StatusController < ApplicationController
  def show
    skip_authorization
    render text: 'ok'
  end
end
