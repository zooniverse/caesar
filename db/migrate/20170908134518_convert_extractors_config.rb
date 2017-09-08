class ConvertExtractorsConfig < ActiveRecord::Migration[5.1]
  def change
    Extractor.delete_all

    Workflow.find_each do |workflow|
      Workflow::ConvertLegacyExtractorsConfig.new(workflow).update(workflow.extractors_config)
    end
  end
end
