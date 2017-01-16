class ReceiveKinesisPayload
  def self.run!(params)
    new(params).execute
  end

  attr_reader :payload

  def initialize(params)
    @payload = params
  end

  def execute
    ActiveRecord::Base.transaction do
      payload.each do |stream_event|
        process(stream_event)
      end
    end
  end

  def process(stream_event)
    return unless stream_event.fetch("source") == "panoptes"
    return unless stream_event.fetch("type") == "classification"

    stream_event.fetch("linked").fetch("workflows").each do |workflow|
      Workflow.update_cache(workflow)
    end

    stream_event.fetch("linked").fetch("subjects").each do |subject|
      Subject.update_cache(subject)
    end

    classification = Classification.new(stream_event.fetch("data"))
    workflow = Workflow.find(classification.workflow_id)
    workflow.classification_pipeline.process(classification)
  end
end
