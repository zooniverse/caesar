module Rules
  class RetireSubject < Effect
    attr_reader :panoptes, :reason

    def initialize(panoptes:, reason: "other")
      @panoptes = panoptes
      @config = config
    end

    def perform(workflow, subject)
      panoptes.retire_subject(workflow.id, subject.id, reason: reason)
    end
  end
end
