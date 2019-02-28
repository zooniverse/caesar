class AddExtractorsCountToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :extractors_count, :int
  end
end
