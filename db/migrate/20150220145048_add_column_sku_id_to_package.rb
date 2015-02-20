class AddColumnSkuIdToPackage < ActiveRecord::Migration
  def change
    add_column :packages, :sku_id, :integer
  end
end
