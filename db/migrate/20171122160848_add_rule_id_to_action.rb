class AddRuleIdToAction < ActiveRecord::Migration[5.1]
  def change
    add_column :actions, :rule_id, :integer
  end
end
