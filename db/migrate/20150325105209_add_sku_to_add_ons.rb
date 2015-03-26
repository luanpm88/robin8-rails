class AddSkuToAddOns < ActiveRecord::Migration
  def change
    add_column :add_ons,:validity,:integer #in days
    add_column :add_ons,:sku_id,:integer
  end
end
