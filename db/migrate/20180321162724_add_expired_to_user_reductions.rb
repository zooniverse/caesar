class AddExpiredToUserReductions < ActiveRecord::Migration[5.1]
  def change
    add_column :user_reductions, :expired, :boolean, default: false
  end
end
