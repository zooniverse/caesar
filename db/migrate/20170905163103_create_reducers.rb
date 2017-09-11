class CreateReducers < ActiveRecord::Migration[5.1]
  def change
    create_table :reducers do |t|
      t.references :workflow, foreign_key: true
      t.string :key, null: false
      t.string :type, null: false
      t.string :grouping

      t.jsonb :config, null: false, default: {}
      t.jsonb :filters, null: false, default: {}

      t.timestamps
    end
  end
end
