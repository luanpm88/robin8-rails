class CreateEWalletPromotions < ActiveRecord::Migration
  def change
    create_table :e_wallet_promotions do |t|
      t.string :title
      t.text   :description
      t.float :min_amount, default: 0
      t.float :max_amount, default: 0
      t.datetime :start_at
      t.datetime :end_at
      t.string :promotion_way
      t.float :extra_percentage
      t.boolean :state, default: true
      t.timestamps null: false
    end
  end
end
