class AlterExtractorId < ActiveRecord::Migration[5.0]
  def change
    change_column :extracts, :extractor_id, :string, null: false
  end
end
