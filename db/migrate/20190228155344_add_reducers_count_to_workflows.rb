class AddReducersCountToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :reducers_count, :int
  end
end
