class AddColumnsToUserReductions < ActiveRecord::Migration[5.1]
  def change
    add_column :user_reductions, :lock_version, :int, default: 0, null: false
    add_column :user_reductions, :store, :jsonb
  end
end
