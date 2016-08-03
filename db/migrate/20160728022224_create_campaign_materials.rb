class CreateCampaignMaterials < ActiveRecord::Migration
  def change
    create_table :campaign_materials do |t|
      t.integer :campaign_id
      t.string :url_type
      t.string :url

      t.timestamps null: false
    end
  end
end
