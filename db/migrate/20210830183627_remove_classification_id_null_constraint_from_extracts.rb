class RemoveClassificationIdNullConstraintFromExtracts < ActiveRecord::Migration[5.2]
  def change
    change_column_null :extracts, :classification_id, true
  end
end
