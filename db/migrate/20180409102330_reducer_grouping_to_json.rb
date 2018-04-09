class ReducerGroupingToJson < ActiveRecord::Migration[5.1]
  def change
    rename_column :reducers, :grouping, :string_grouping
    add_column :reducers, :grouping, :jsonb, null: false, default: {}
    Reducer.where.not(string_grouping: nil).each do |reducer|
      reducer.update(grouping: {field_name: reducer.string_grouping, if_missing: 'ignore'})
    end
    remove_column :reducers, :string_grouping
  end
end
