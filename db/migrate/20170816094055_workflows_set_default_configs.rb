class WorkflowsSetDefaultConfigs < ActiveRecord::Migration[5.1]
  def change
    change_column_default :workflows, :extractors_config, {}
    change_column_default :workflows, :reducers_config, {}
    change_column_default :workflows, :rules_config, []
    change_column_default :workflows, :webhooks_config, []

    Workflow.where("extractors_config IS NULL").update_all(extractors_config: {})
    Workflow.where("reducers_config IS NULL").update_all(reducers_config: {})
    Workflow.where("rules_config IS NULL").update_all(rules_config: [])
    Workflow.where("webhooks_config IS NULL").update_all(webhooks_config: [])

    change_column_null :workflows, :extractors_config, false
    change_column_null :workflows, :reducers_config, false
    change_column_null :workflows, :rules_config, false
    change_column_null :workflows, :webhooks_config, false
  end
end
