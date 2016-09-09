class CreateCpsPromotionMaterials < ActiveRecord::Migration
  def change
    create_table :cps_promotion_materials do |t|
      t.integer :kol_id
      t.integer :cps_article_share_id
      t.integer :cps_material_id

      t.text :wl_promotion_url
      t.text :pc_promotion_url

      t.timestamps null: false
    end
  end
end
