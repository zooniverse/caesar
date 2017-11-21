class AddUserIdToAction < ActiveRecord::Migration[5.1]
  def change
    add_column :actions, :user_id, :integer
  end
end
