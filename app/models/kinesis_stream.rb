class KinesisStream
  attr_reader :payload

  def receive(payload)
    ActiveRecord::Base.transaction do
      payload.each do |event|
        process(StreamEvent.from(event))
      end
    end
  end

  def process(stream_event)
    return unless stream_event.enabled?

    Workflow.update_cache(stream_event.workflow)

    stream_event.subjects.each do |subject|
      Subject.update_cache(subject)
    end

    classification = stream_event.classification
    workflow = Workflow.find(classification.workflow_id)
    workflow.classification_pipeline.process(classification)
  end
end
