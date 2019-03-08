class RemoveExpiredFromUserReductions < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_reductions, :expired, :boolean
  end
end
