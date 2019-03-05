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

      self.path = Rails.root.join("tmp", "#{request.id}.csv")

      request.processing!

      exporter = Exporters::CsvExporter.new(
        resource_id: request.exportable.id,
        resource_type: request.exportable.class.name,
        user_id: request.user_id,
        subgroup: request.subgroup,
        requested_data: request.requested_data
      )

      exporter.dump(path) do |progress, total|
        if progress % 1000 == 0
          request.records_count = total
          request.records_exported = progress
          request.save
        end
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
