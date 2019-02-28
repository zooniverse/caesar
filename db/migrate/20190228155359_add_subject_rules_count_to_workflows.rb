class AddSubjectRulesCountToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :subject_rules_count, :int
  end
end
