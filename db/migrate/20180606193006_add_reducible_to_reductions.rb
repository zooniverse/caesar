class AddReducibleToReductions < ActiveRecord::Migration[5.1]
  def change
    add_column :reducers, :reducible_id, :string
    add_column :reducers, :reducible_type, :string

    add_column :user_reductions, :reducible_id, :string
    add_column :user_reductions, :reducible_type, :string

    add_column :subject_reductions, :reducible_id, :string
    add_column :subject_reductions, :reducible_type, :string
  end
end
