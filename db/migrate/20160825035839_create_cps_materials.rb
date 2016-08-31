class CreateCpsMaterials < ActiveRecord::Migration
  def change
    create_table :cps_materials do |t|
      t.string :sku_id, :limit => 20, :uniq => true
      t.string :img_url
      t.string :material_url
      t.string :shop_id
      t.float :unit_price
      t.date  :start_date
      t.date  :end_date
      t.float :commision_ration_pc
      t.float :commision_ration_wl
      t.float :commision_pc
      t.float :commision_wl
      t.float :kol_commision_pc
      t.float :kol_commision_wl
      t.string :goods_name
      t.string :category
      t.integer :shop_id
      t.datetime :last_sync_at

      t.boolean :enabled, :default => true
      t.integer :position, :default => 0

      t.timestamps null: false
    end

    add_index :cps_materials, :sku_id
  end
end
