class RemoveOldTables < ActiveRecord::Migration
  def change
    rename_table :subscriptions ,:user_products
    rename_column :user_products,:package_id,:product_id
    rename_column :payments,:payable_id,:user_product_id
    remove_column :payments,:payable_type,:string
    remove_column :payments,:orderable_type,:string
    rename_column :payments,:orderable_id,:product_id

    rename_column :user_features,:used_count,:available_count

    drop_table :add_ons
    drop_table :user_add_ons

    remove_column :payments,:user_id,:integer
    remove_column :user_features,:count,:integer
    remove_column :user_products,:total_amount,:integer
    add_column :user_products,:bluesnap_order_id,:integer
  end
end
