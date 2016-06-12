class ChangeColumnIdentityPriceType < ActiveRecord::Migration
  def change
    change_column :kol_identity_prices, :headline_price, :string
    change_column :kol_identity_prices, :second_price, :string
    change_column :kol_identity_prices, :single_price, :string
    change_column :kol_identity_prices, :follower_count, :string
  end
end
