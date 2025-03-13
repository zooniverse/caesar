module Effects
  class RetireSubject < Effect
    CONFIG_CHOICES = ["classification_count", "flagged", "nothing_here",
                      "blank", "consensus", "other", "human"]

    def perform(workflow_id, subject_id)
      light = Stoplight("retire-subjects-#{workflow_id}-#{subject_id}") do
        Effects.panoptes.retire_subject(workflow_id, subject_id, reason: reason)
      end
      light.run
    rescue Panoptes::Client::ServerError
      raise
    end

    def valid?
      reason.present?
    end

    def self.config_fields
      # use 2-element response (key, choices) to enable dropdown in
      # subject_rule_effect _form view, or 1-element (key) for text input
      [[:reason, CONFIG_CHOICES]].freeze
    end

    def reason
      config["reason"] || "other"
    end
  end
end
