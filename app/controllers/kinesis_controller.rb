class KinesisController < ApplicationController
  def create
    ReceiveKinesisPayload.run!(params["_json"])
    head :no_content
  end
end
