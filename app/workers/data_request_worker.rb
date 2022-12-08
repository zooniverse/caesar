class DataRequestWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5
  sidekiq_options queue: 'batch'
  sidekiq_retry_in do |count|
    (count ** 8) + 15 + (rand(30) * count + 1)
  end

  attr_accessor :path

  def perform(request_id)
    begin
      request = DataRequest.find(request_id)
      return if request.processing? || request.complete?
      request.processing! unless request.canceling?

      self.path = Rails.root.join("tmp", "#{request.id}.csv")

      exporter = Exporters::CsvExporter.new(
        resource_id: request.exportable.id,
        resource_type: request.exportable.class.name,
        user_id: request.user_id,
        subgroup: request.subgroup,
        requested_data: request.requested_data
      )

      related_counter = "#{request.requested_data}_count"

      # use the counter cache, if possible, to estimate the number of
      # rows, since querying the table is too expensive in many cases
      estimated_count = nil
      estimated_count = request.exportable.send(related_counter) || 0 if request.simple?
      actual_count = 0

      exporter.dump(path, estimated_count: estimated_count) do |progress, total|
        actual_count += 1
        if progress.positive? && (progress % progress_interval).zero?
          raise DataRequest::DataRequestCanceled, 'data request cancelled!' if request.reload.canceling?

          request.records_count = total
          request.records_exported = progress
          # if we've exported more records than we thought we would, update the records count
          request.records_count = request.records_exported if request.records_exported > request.records_count
          request.save
        end
      end

      # if our estimated count was from the counter_cache and it was off by enough, then
      # use the value we know to be correct to update the counter cache
      if request.simple? && ((actual_count - estimated_count).abs > 100)
        request.exportable.class.update_counters request.exportable.id, { related_counter => (actual_count-estimated_count)}
      end
      request.stored_export.upload(path)
      # ensure we update the data request with the total count of exported records
      request.records_count = actual_count
      request.status = 'complete'
      request.save
    rescue DataRequest::DataRequestCanceled
      DataRequest.find(request_id).canceled!
    rescue Exception          # bare rescue only rescues StandardError
      request.failed!
      raise
    ensure
      # cleanup the resulting export file - this should really have been a tmp file
      ::File.unlink path if path.present? && ::File.exist?(path)
    end
  end

  def progress_interval
    @progress_interval ||= 1000
  end
end
