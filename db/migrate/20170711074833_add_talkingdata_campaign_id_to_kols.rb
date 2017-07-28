class AddTalkingdataCampaignIdToKols < ActiveRecord::Migration
  def change
    add_column :kols, :talkingdata_campaign_id, :string
  end
end
