class AddRechargeFromToAlipayOrders < ActiveRecord::Migration
  def change
    add_columns :alipay_orders, :recharge_from, :string
  end
end
