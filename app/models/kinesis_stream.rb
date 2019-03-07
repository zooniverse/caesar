class KinesisStream
  def receive(payload)
    results = ActiveRecord::Base.transaction do
      payload.map { |event| StreamEvents.from(event).process }
    end

    results.each do |result|
      case result
      when Classification
        ExtractWorker.perform_async(classification.id) unless classification.workflow.paused?
      else
        # nothing to enqueue
      end
    end
  end
end
