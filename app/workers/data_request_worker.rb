class DataRequestWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  def perform(request_id)
    request = DataRequest.find(request_id)

    return unless request.status == DataRequest::PENDING

    exporter = nil

    request.status = DataRequest::PROCESSING
    request.save

    begin
      exporter = case request.requested_data
      when DataRequest::EXTRACTS
        CsvExtractExporter
      when DataRequest::REDUCTIONS
        CsvReductionExporter
      end.new(
        :workflow_id => request.workflow_id,
        :user_id => request.user_id,
        :subgroup => request.subgroup
      )

      exporter.dump("tmp/#{request.id}.csv")
      # TODO: put this file to S3

      request.status = DataRequest::COMPLETE
      request.save
    rescue
      request.status = DataRequest::FAILED
      request.save
    end
  end
end
