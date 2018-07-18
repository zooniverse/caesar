module Effects
  class RetireSubject < Effect
    def perform(workflow_id, subject_id)
      Effects.panoptes.retire_subject(workflow_id, subject_id, reason: reason)
    end

    def valid?
      reason.present?
    end

    def self.config_fields
      ["reason"]
    end

    def reason
      config["reason"] || "other"
    end
  end
end
