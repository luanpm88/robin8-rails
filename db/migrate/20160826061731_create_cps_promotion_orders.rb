class CreateCpsPromotionOrders < ActiveRecord::Migration
  def change
    create_table :cps_promotion_orders do |t|
      t.integer :kol_id
      t.integer :cps_article_share_id
      t.integer :split_type
      t.string :order_id, :limit => 20
      t.datetime :order_time
      t.string :parent_id
      t.integer :pop_id
      t.string :source_emt
      t.float :total_money
      t.boolean :yn                                          # from order
      t.string :status, :default => 'pending'
      t.string :sub_union, :limit => 40
      t.string :order_query_time, :limit => 40
      t.string :receipt_query_time, :limit => 40           # from commision
      t.float :cos_price                                  # update from commision
      t.float :commision_fee                               # from commision


      t.timestamps null: false
    end
    add_index :cps_promotion_orders, :kol_id
    add_index :cps_promotion_orders, :cps_article_share_id
    add_index :cps_promotion_orders, :order_id
    add_index :cps_promotion_orders, :order_query_time
    add_index :cps_promotion_orders, :receipt_query_time
  end
end
