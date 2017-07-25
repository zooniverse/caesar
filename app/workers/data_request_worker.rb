class DataRequestWorker
  include Sidekiq::Worker

  def perform(request_id)
    request = DataRequest.find(request_id)

    return unless request.status == DataRequest::PENDING

    exporter = nil

    request.status = DataRequest::PROCESSING
    request.save

    begin
      case request.requested_data
      when DataRequest::EXTRACTS
        exporter = CsvExtractExporter.new
      when DataRequest::REDUCTIONS
        exporter = CsvReductionExporter.new
      end

      exporter.dump(request.workflow_id, "tmp/#{request.id}.csv")
      # TODO: put this file to S3

      request.status = DataRequest::COMPLETE
      request.save
    rescue
      request.status = DataRequest::FAILED
      request.save
    end
  end
end
