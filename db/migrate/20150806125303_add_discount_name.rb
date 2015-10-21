class AddDiscountName < ActiveRecord::Migration
  def change
    add_column :discounts,:discount_name,:string,:default => nil
  end
end
