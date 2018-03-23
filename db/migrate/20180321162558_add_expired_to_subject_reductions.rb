class AddExpiredToSubjectReductions < ActiveRecord::Migration[5.1]
  def change
    add_column :subject_reductions, :expired, :boolean, default: false
  end
end
