class AddMachineDataToExtracts < ActiveRecord::Migration[5.2]
  def change
    add_column :extracts, :machine_data, :boolean
    change_column_default :extracts, :machine_data, false
  end
end
