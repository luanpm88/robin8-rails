class AddTaxToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :tax, :float, default: 0
  end
end
