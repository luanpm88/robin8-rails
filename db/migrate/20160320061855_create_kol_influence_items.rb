class CreateKolInfluenceItems < ActiveRecord::Migration
  def change
    create_table :kol_influence_items do |t|
      t.integer :kol_id
      t.string :kol_uuid
      t.string :item_name
      t.string :item_value
      t.string :item_score
      t.text :item_detail_content

      t.timestamps null: false
    end

    create_table :tmp_kol_influence_items do |t|
      t.integer :kol_id
      t.string :kol_uuid
      t.string :item_name
      t.string :item_value
      t.string :item_score
      t.text :item_detail_content

      t.timestamps null: false
    end
  end
end
