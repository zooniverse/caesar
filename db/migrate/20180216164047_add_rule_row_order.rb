class AddRuleRowOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :subject_rules, :row_order, :integer
    add_column :user_rules, :row_order, :integer
  end
end
