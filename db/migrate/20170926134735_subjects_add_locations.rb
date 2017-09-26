class SubjectsAddLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :subjects, :locations, :jsonb, default: {}, null: false
  end
end
