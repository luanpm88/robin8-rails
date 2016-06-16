class AddRechargeFromToAlipayOrders < ActiveRecord::Migration
  def change
    add_column :alipay_orders, :recharge_from, :string
  end
end
