class CreateCampaignActionUrls < ActiveRecord::Migration
  def change
    create_table :campaign_action_urls do |t|
      t.references :kol
      t.references :campaign
      t.string     :action_url
      t.string     :short_url
      t.timestamps null: false
    end
  end
end
