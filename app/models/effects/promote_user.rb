module Effects
  class PromoteUser < Effect
    def perform(workflow_id, user_id)
      project_id = Workflow.find(workflow_id).project_id
      @stoplight_id = "promote-user-to-workflow-#{workflow_id}-#{user_id}"
      light = Stoplight(@stoplight_id) do
        Effects.panoptes.promote_user_to_workflow(user_id, project_id, target_workflow_id)
      end
      light.run
    rescue Panoptes::Client::ServerError
      raise
    end

    def valid?
      target_workflow_id.present?
    end

    def self.config_fields
      [:workflow_id].freeze
    end

    def target_workflow_id
      config.fetch("workflow_id", nil)
    end
  end
end
