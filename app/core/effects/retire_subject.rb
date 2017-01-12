module Effects
  class RetireSubject < Effect
    def perform(workflow, subject)
      Panoptes.retire_subject(workflow.id, subject.id, reason: reason)
    end

    def reason
      config["reason"] || "other"
    end
  end
end
