class DropRetirementColumn < ActiveRecord::Migration[5.0]
  def change
    remove_column :workflows, :retirement
  end
end
