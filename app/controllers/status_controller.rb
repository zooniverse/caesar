class StatusController < ApplicationController
  skip_before_action :authorize!

  def show
    render text: 'ok'
  end
end
