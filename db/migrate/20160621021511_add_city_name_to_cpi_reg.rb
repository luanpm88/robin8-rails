class AddCityNameToCpiReg < ActiveRecord::Migration
  def change
    add_column :cpi_regs, :city_name, :string
  end
end
