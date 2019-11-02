module Effects
  class RetireSubject < Effect

    CONFIG_CHOICES = ["classification_count", "flagged", "nothing_here", "blank", "consensus", "other", "human"]

    def perform(workflow_id, subject_id)
      Effects.panoptes.retire_subject(workflow_id, subject_id, reason: reason)
    end

    def valid?
      reason.present?
    end

    def self.config_fields
      [[:reason, CONFIG_CHOICES]].freeze
    end

    def reason
      config["reason"] || "other"
    end
  end
end
