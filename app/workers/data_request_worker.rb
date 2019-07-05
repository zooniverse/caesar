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
      request.processing!

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
      estimated_count = if request.simple?
       (request.exportable.send related_counter) || 0
      else
        nil
      end

      actual_count = 0

      exporter.dump(path, estimated_count: estimated_count) do |progress, total|
        actual_count += 1
        if progress % 1000 == 0
          request.records_count = total
          request.records_exported = progress

          if request.records_exported > request.records_count
            request.records_count = request.records_exported
          end

          request.save
        end
      end

      # if our estimated count was from the counter_cache and it was off by enough, then
      # use the value we know to be correct to update the counter cache
      if request.simple? && ((actual_count - estimated_count).abs > 100)
        request.exportable.class.update_counters request.exportable.id, { related_counter => (actual_count-estimated_count)}
      end

      request.stored_export.upload(path)
      request.complete!
    rescue Exception          # bare rescue only rescues StandardError
      request.failed!
      raise
    ensure
      if(path.present? and ::File.exists?(path))
        ::File.unlink path
      end
    end
  end
end
