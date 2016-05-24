class AddTaxToAlipayOrder < ActiveRecord::Migration
  def change
    add_column :alipay_orders, :tax, :decimal, :precision => 8, :scale => 2, default: 0
  end
end
