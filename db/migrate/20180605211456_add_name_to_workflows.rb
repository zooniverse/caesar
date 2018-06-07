class AddNameToWorkflows < ActiveRecord::Migration[5.1]
  def change
    add_column :workflows, :name, :string
  end
end
