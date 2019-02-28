class AddReducersCountToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :reducers_count, :int
  end
end
