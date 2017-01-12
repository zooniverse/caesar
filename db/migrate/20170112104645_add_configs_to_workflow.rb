class AddConfigsToWorkflow < ActiveRecord::Migration[5.0]
  def change
    add_column :workflows, :extractors_config, :jsonb
    add_column :workflows, :reducers_config, :jsonb
    add_column :workflows, :rules_config, :jsonb
  end
end
