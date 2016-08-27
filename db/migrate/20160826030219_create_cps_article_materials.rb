class CreateCpsArticleMaterials < ActiveRecord::Migration
  def change
    create_table :cps_article_materials do |t|
      t.integer :cps_article_id
      t.integer :cps_material_id


      t.timestamps null: false
    end
  end
end
