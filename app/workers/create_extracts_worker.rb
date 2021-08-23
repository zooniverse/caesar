# frozen_string_literal: true
class CreateExtractsWorker
  include Sidekiq::Worker

  def perform(options, workflow_id)
    options.symbolize_keys!
    Extract.create!(
      workflow_id: workflow_id,
      subject_id: options[:subject_id],
      classification_at: DateTime.now,
      machine_data: options[:machine_data],
      extractor_key: options[:extractor_key],
      data: options[:data],
      classification_id: 0
    )
  end
end
