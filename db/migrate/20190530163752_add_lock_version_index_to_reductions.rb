class AddLockVersionIndexToReductions < ActiveRecord::Migration[5.2]
  def change
    if index_exists?(:user_reductions, [:id, :lock_version])
      remove_index :user_reductions, [:id, :lock_version]
    end

    unless index_exists?(:user_reductions, [:id, :lock_version])
      add_index :user_reductions, [:id, :lock_version]
    end

    if index_exists?(:subject_reductions, [:id, :lock_version])
      remove_index :subject_reductions, [:id, :lock_version]
    end

    unless index_exists?(:subject_reductions, [:id, :lock_version])
      add_index :subject_reductions, [:id, :lock_version]
    end
  end
end
