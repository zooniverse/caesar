class AddExtractsCountToWorkflows < ActiveRecord::Migration[5.1]
  def change
    add_column :workflows, :extracts_count, :int
  end
end
