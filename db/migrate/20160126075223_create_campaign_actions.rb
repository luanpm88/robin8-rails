class CreateCampaignActions < ActiveRecord::Migration
  def change
    create_table :campaign_actions do |t|
      t.integer :kol_id
      t.integer :campaign_id
      t.integer :campaign_invite_id
      t.string :action
      t.timestamps null: false
    end
  end
end
