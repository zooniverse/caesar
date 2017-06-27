class CreateCredentials < ActiveRecord::Migration[5.1]
  def change
    create_table :credentials do |t|
      t.text :token, null: false, index: {unique: true}
      t.string :refresh, null: true
      t.datetime :expires_at, null: false, default: "NOW()"
      t.integer :project_ids, array: true, default: [], null: false

      t.timestamps
    end
  end
end
