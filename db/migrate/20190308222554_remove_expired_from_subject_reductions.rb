class RemoveExpiredFromSubjectReductions < ActiveRecord::Migration[5.2]
  def change
    remove_column :subject_reductions, :expired, :boolean
  end
end
