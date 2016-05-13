class CreateAlipayOrders < ActiveRecord::Migration
  def change
    create_table :alipay_orders do |t|
      t.string :trade_no
      t.string :alipay_trade_no
      t.decimal :credits, :precision => 8, :scale => 2
      t.string :status, default: "pending"
      t.string :user_id

      t.timestamps null: false
    end
    add_index :alipay_orders, :trade_no, :unique => true
  end
end
