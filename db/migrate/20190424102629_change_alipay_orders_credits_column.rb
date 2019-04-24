class ChangeAlipayOrdersCreditsColumn < ActiveRecord::Migration
  def change
    change_column :alipay_orders, :credits, :decimal, :precision => 16, :scale => 2
  end
end
