class CreateActions < ActiveRecord::Migration[5.0]
  def change
    create_table :actions do |t|
      t.references :workflow, null: false, index: true, foreign_key: true
      t.references :subject, null: false, index: true, foreign_key: true

      t.string :effect_type, null: false
      t.jsonb :config, default: {}, null: false
      t.integer :status, default: 0, null: false
      t.timestamp :attempted_at
      t.timestamp :completed_at

      t.timestamps
    end
  end
end
