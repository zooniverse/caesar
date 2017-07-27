require 'uploader'

class DataRequestWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  attr_accessor :path

  def perform(request_id)
    request = DataRequest.find(request_id)
    return unless request.status == DataRequest::PENDING

    self.path = "tmp/#{request.id}.csv"

    request.status = DataRequest::PROCESSING
    request.save

    begin
      exporter = case request.requested_data
      when DataRequest::EXTRACTS
        Exporters::CsvExtractExporter
      when DataRequest::REDUCTIONS
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
      request.status = DataRequest::COMPLETE
      request.save
    rescue
      request.status = DataRequest::FAILED
      request.save
    end
  end
end
