class AddForeignKeysToPendingClassifications < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key "pending_classifications", "workflows", on_delete: :cascade
    add_foreign_key "pending_classifications", "classifications", on_delete: :cascade
  end
end
