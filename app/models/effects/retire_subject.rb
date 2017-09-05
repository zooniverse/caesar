module Effects
  class RetireSubject < Effect
    def perform(workflow_id, subject_id)
      Effects.panoptes.retire_subject(workflow_id, subject_id, reason: reason)

      notify_subscribers(workflow_id, :subject_retired, {
        "subject_id" => subject_id,
        "workflow_id" => workflow_id
      })
    end

    def valid?
      reason.present?
    end

    def reason
      config["reason"] || "other"
    end
  end
end
