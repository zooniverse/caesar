class SetWorkflowCounterCacheDefaults < ActiveRecord::Migration[5.2]
  def change
    change_column_default :workflows, :extracts_count, 0
    change_column_default :workflows, :subject_reductions_count, 0
    change_column_default :workflows, :user_reductions_count, 0
    change_column_default :workflows, :subject_actions_count, 0
    change_column_default :workflows, :user_actions_count, 0
    change_column_default :workflows, :extractors_count, 0
    change_column_default :workflows, :reducers_count, 0
    change_column_default :workflows, :subject_rules_count, 0
    change_column_default :workflows, :user_rules_count, 0
  end
end
