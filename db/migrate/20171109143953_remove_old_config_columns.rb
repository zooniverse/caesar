class RemoveOldConfigColumns < ActiveRecord::Migration[5.1]
  def change
    remove_column(:workflows, :extractors_config, :jsonb)
    remove_column(:workflows, :reducers_config, :jsonb)
    remove_column(:workflows, :rules_config, :jsonb)
  end
end
