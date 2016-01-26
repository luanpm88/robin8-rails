class CreateCampaignLikes < ActiveRecord::Migration
  def change
    create_table :campaign_likes do |t|
      t.integer :kol_id
      t.integer :campaign_id
      t.boolean :like
      t.boolean :hide

      t.timestamps null: false
    end
  end
end
