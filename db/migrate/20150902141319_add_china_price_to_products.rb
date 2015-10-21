class AddChinaPriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :china_price, :float
  end
end
