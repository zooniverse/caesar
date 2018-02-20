class SetDefaultRowOrder < ActiveRecord::Migration[5.1]
  def change
    SubjectRule.where("row_order IS NULL").update_all("row_order = id")
    UserRule.where("row_order IS NULL").update_all("row_order = id")
  end
end
