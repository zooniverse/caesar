class ConvertReducerConfig < ActiveRecord::Migration[5.1]
  def change
    Reducer.delete_all

    Workflow.find_each do |workflow|
      workflow.reducers_config.each do |key, reducer_config|
        reducer = reducer_type(reducer_config).new(workflow: workflow, key: key)
        reducer.config = reducer_config.except("filters", "grouping", "group_by", "type")
        reducer.grouping = reducer_config["group_by"] || reducer_config["grouping"] || nil
        reducer.filters = reducer_config["filters"] || {}
        reducer.save!
      end
    end

  end

  def reducer_type(reducer_config)
    case reducer_config["type"].to_s
    when "count"
      Reducers::CountReducer
    when "external"
      Reducers::ExternalReducer
    when "stats"
      Reducers::StatsReducer
    when "consensus"
      Reducers::ConsensusReducer
    when "unique_count"
      Reducers::UniqueCountReducer
    else
      raise "Reducer misconfigured: unknown type #{reducer_config["type"]}"
    end
  end
end
