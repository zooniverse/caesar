class RenameExtractorAndReducerIdToKey < ActiveRecord::Migration[5.1]
  def change
    rename_column :extracts, :extractor_id, :extractor_key
    rename_column :reductions, :reducer_id, :reducer_key

    Workflow.find_each do |workflow|
      workflow.extractors_config
    end
  end
end
