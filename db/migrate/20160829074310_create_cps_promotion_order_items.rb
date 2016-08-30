class CreateCpsPromotionOrderItems < ActiveRecord::Migration
  def change
    create_table :cps_promotion_order_items do |t|
      t.integer :cps_promotion_order_id
      t.integer :first_level
      t.integer :second_level
      t.integer :third_level
      t.string :product_id
      t.integer :quantity
      t.float :total_price
      t.string :ware_id
      t.float :yg_cos_fee

      t.float :cos_fee        #订单业绩返回
      t.integer :return_num   #订单业绩返回

      t.string :status  #pending,canceled, finished, return_part, settled



      t.timestamps null: false
    end
  end
end
