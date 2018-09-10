class AddUserReductionsCountToWorkflows < ActiveRecord::Migration[5.1]
  def change
    add_column :workflows, :user_reductions_count, :int
  end
end
