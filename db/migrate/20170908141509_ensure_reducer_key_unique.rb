class EnsureReducerKeyUnique < ActiveRecord::Migration[5.1]
  def change
    add_index :reducers, [:workflow_id, :key], unique: true
  end
end
