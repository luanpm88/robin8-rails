class AddCountToAddOns < ActiveRecord::Migration
  def change
    add_column :add_ons,:count,:integer,:default=>1
    rename_column :user_add_ons,:available_count,:count
    add_column :add_ons,:is_recurring,:boolean,:default => false
    add_column :add_ons,:recurring_interval,:integer
  end
end
