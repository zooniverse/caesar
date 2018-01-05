module Effects
  class PromoteUser < Effect
    def perform(workflow_id, subject_id)
      # Effects.panoptes.retire_subject(workflow_id, subject_id, reason: reason)

      notify_subscribers(workflow_id, :user_promoted, {
        "subject_id" => subject_id,
        "workflow_id" => workflow_id
      })
    end

    def valid?
      true
    end
  end
end
