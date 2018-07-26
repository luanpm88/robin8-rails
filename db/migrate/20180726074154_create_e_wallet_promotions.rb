class CreateEWalletPromotions < ActiveRecord::Migration
  def change
    create_table :e_wallet_promotions do |t|
      t.string :title
      t.text   :description
      t.integer :min_amount
      t.integer :max_amount
      t.datetime :start_at
      t.datetime :end_at
      t.string :promotion_way
      t.integer :extra_percentage
      t.boolean :state, default: true
      t.timestamps null: false
    end
  end
end
