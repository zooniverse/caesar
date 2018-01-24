module Effects
  class PromoteUser < Effect
    def perform(workflow_id, user_id)
      project_id = Workflow.find(workflow_id).project_id
      Effects.panoptes.promote_user_to_workflow(user_id, project_id, workflow_id)

      notify_subscribers(workflow_id, :user_promoted, {
        "user_id" => user_id,
        "target_workflow_id" => workflow_id
      })
    end

    def valid?
      target_workflow_id.present?
    end

    def target_workflow_id
      config.fetch("workflow_id", nil)
    end
  end
end
