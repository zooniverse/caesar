class AddLockVersionIndexToReductions < ActiveRecord::Migration[5.2]
  def change
    add_index :user_reductions, [:id, :lock_version], unique: true, algorithm: :concurrently
    add_index :subject_reductions, [:id, :lock_version], unique: true, algorithm: :concurrently
  end
end
