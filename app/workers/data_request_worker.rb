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
      return unless request.pending?

      self.path = Rails.root.join("tmp", "#{request.id}.csv")

      request.processing!

      exporter = if request.extracts?
        Exporters::CsvExtractExporter
      elsif request.reductions?
        Exporters::CsvSubjectReductionExporter
      end.new(
        :workflow_id => request.workflow_id,
        :user_id => request.user_id,
        :subgroup => request.subgroup
      )

      exporter.dump(path)

      request.stored_export.upload(path)
      request.complete!
    rescue
      request.failed!
      raise
    ensure
      ::File.unlink path
    end
  end
end
