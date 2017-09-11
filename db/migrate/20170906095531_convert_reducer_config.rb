class ConvertReducerConfig < ActiveRecord::Migration[5.1]
  def change
    Reducer.delete_all

    Workflow.find_each do |workflow|
      Workflow::ConvertLegacyReducersConfig.new(workflow).update(workflow.reducers_config)
    end
  end
end
