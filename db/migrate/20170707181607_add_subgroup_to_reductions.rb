class AddSubgroupToReductions < ActiveRecord::Migration[5.1]
  def change
    add_column :reductions, :subgroup, :string
  end
end
