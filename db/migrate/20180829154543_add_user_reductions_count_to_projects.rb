class AddUserReductionsCountToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :user_reductions_count, :int
  end
end
