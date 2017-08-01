class DefaultValueForReductionSubgroup < ActiveRecord::Migration[5.1]
  def change
    change_column :reductions, :subgroup, :string, :default => "_default"
    Reduction.update_all(:subgroup => "_default")
  end
end
