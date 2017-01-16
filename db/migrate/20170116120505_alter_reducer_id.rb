class AlterReducerId < ActiveRecord::Migration[5.0]
  def change
    change_column :reductions, :reducer_id, :string, null: false
  end
end
