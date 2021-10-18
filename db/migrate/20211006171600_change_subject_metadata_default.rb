class ChangeSubjectMetadataDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :subjects, :metadata, {}
  end
end
