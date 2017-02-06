module StreamEvents
  class ClassificationEvent
    def initialize(hash)
      @data = hash.fetch("data")
      @linked = StreamEvents.linked_to_hash(hash.fetch("linked"))
    end

    def process
      return unless enabled?

      cache_linked_models!

      ExtractWorker.perform_async(classification.workflow_id, @data.to_unsafe_h)
    end

    def cache_linked_models!
      Workflow.update_cache(linked_workflow)

      linked_subjects.each do |linked_subject|
        Subject.update_cache(linked_subject)
      end
    end

    private

    def enabled?
      linked_workflow.fetch("retirement").key?("caesar")
    end

    def classification
      @classification ||= Classification.new(@data)
    end

    def linked_workflow
      id = @data.fetch("links").fetch("workflow")
      @linked.fetch("workflows").fetch(id)
    end

    def linked_subjects
      @linked.fetch("subjects").values
    end
  end
end
