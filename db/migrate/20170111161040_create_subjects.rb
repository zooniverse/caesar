class CreateSubjects < ActiveRecord::Migration[5.0]
  def change
    create_table :subjects do |t|
      t.jsonb :metadata

      t.timestamps
    end
  end
end
