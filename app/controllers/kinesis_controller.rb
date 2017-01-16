class KinesisController < ApplicationController
  def create
    kinesis_stream.receive(params["_json"])
    head :no_content
  end

  private

  def kinesis_stream
    KinesisStream.new
  end
end
