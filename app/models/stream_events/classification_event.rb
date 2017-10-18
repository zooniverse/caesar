module StreamEvents
  class ClassificationEvent
    attr_reader :stream

    def initialize(stream, hash)
      @stream = stream
      @data = hash.fetch("data")
      @linked = StreamEvents.linked_to_hash(hash.fetch("linked"))
    end

    def process
      return unless enabled?

      cache_linked_models!

      if workflow.subscribers?
        workflow.webhooks.process "new_classification", @data.as_json
      end

      stream.queue.add(ExtractWorker, classification.id)
    end

    def cache_linked_models!
      linked_subjects.each do |linked_subject|
        Subject.update_cache(linked_subject)
      end
    end

    private

    def enabled?
      workflow.present?
    end

    def classification
      @classification ||= Classification.upsert(@data.to_unsafe_h)
    end

    def workflow
      workflow_id = @data.fetch("links").fetch("workflow")
      Workflow.find_by(id: workflow_id)
    end

    def subject
      subject_id = @data.fetch("links").fetch("subjects")[0]
      Subject.find(subject_id)
    end

    def linked_subjects
      @linked.fetch("subjects").values
    end
  end
end
