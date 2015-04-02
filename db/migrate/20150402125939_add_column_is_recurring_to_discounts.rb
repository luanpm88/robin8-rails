class AddColumnIsRecurringToDiscounts < ActiveRecord::Migration
  def change
    add_column :discounts,:is_recurring,:boolean,:default => false
    change_column :payments,:amount,:float
  end
end
