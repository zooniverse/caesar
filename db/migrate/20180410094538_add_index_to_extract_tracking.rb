class AddIndexToExtractTracking < ActiveRecord::Migration[5.1]
  def change
      add_index :extracts_user_reductions, [:extract_id, :user_reduction_id], name: 'eur_covering_1'
      add_index :extracts_user_reductions, [:user_reduction_id, :extract_id], name: 'eur_covering_2'
      add_index :extracts_subject_reductions, [:extract_id, :subject_reduction_id], name: 'cur_covering_1'
      add_index :extracts_subject_reductions, [:subject_reduction_id, :extract_id], name: 'cur_covering_2'
  end
end
