class AddTopicToReducers < ActiveRecord::Migration[5.1]
  def change
    add_column :reducers, :topic, :integer, default: 0, null: false
  end
end
