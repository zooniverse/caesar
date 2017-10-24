require 'uploader'

class DataRequestWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  attr_accessor :path

  def perform(request_id)
    request = DataRequest.where(id: request_id).first
    return unless request.present? && request.pending?

    self.path = "tmp/#{request.id}.csv"

    request.processing!

    begin
      exporter = if request.extracts?
        Exporters::CsvExtractExporter
      elsif request.reductions?
        Exporters::CsvReductionExporter
      end.new(
        :workflow_id => request.workflow_id,
        :user_id => request.user_id,
        :subgroup => request.subgroup
      )

      exporter.dump(path)
      uploader = ::Uploader.new ::File.new(path)
      uploader.upload
      ::File.unlink path

      request.url = uploader.url
      request.complete!
    rescue
      request.failed!
      raise
    end
  end
end
