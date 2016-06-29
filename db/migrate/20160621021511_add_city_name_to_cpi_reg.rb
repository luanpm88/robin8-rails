class AddCityNameToCpiReg < ActiveRecord::Migration
  def change
    add_column :cpi_regs, :city_name, :string
    add_column :cpi_regs, :device_uuid, :string , :limit => 100

    add_index :cpi_regs, :device_uuid
  end
end
