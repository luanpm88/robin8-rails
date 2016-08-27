class CreateCpsPromotionOrders < ActiveRecord::Migration
  def change
    create_table :cps_promotion_orders do |t|
      t.integer :kol_id
      t.integer :skuid
      t.integer :split_type
      t.integer :cos_price
      t.string :order_id, :limit => 20
      t.datetime :order_time
      t.string :parent_id
      t.integer :pop_id
      t.string :sourceEmt
      t.float :total_money
      t.integer :yn

      t.timestamps null: false
    end

    add_index :cps_promotion_orders, :order_id
  end
end
