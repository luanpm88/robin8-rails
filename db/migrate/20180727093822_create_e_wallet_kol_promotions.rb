class CreateEWalletKolPromotions < ActiveRecord::Migration
  def change
    create_table :e_wallet_kol_promotions do |t|
      t.text   :description
      t.string :income_way
      t.float :extra_percentage
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :state, default: true
      t.timestamps null: false
    end
  end
end
