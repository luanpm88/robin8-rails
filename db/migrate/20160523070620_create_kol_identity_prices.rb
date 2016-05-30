class CreateKolIdentityPrices < ActiveRecord::Migration
  def change
    create_table :kol_identity_prices do |t|
      t.integer :kol_id
      t.string :provider
      t.string :name
      t.integer :follower_count
      t.string :belong_field
      t.float :headline_price
      t.float :second_price
      t.float :single_price

      t.timestamps null: false
    end
  end
end
