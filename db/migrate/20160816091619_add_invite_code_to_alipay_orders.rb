class AddInviteCodeToAlipayOrders < ActiveRecord::Migration
  def change
    add_column :alipay_orders, :invite_code, :string
    change_column :alipay_orders, :credits, :decimal, precision: 12, scale: 2
  end
end
