class DefaultValueForReductionSubgroup < ActiveRecord::Migration[5.1]
  def change
    change_column :reductions, :subgroup, :string, :default => "default"
    Reduction.update_all(:subgroup => "default")
  end
end
