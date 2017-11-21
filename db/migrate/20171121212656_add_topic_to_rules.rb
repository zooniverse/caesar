class AddTopicToRules < ActiveRecord::Migration[5.1]
  def change
    add_column :rules, :topic, :integer, :default => 0
  end
end
