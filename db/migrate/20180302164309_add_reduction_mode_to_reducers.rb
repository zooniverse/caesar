class AddReductionModeToReducers < ActiveRecord::Migration[5.1]
  def change
    add_column :reducers, :reduction_mode, :int, default: 0, null: false
  end
end
