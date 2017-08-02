class RenameTalkingdataCampaignId < ActiveRecord::Migration
  def change
    rename_column :kols, :talkingdata_campaign_id, :talkingdata_channel_id
  end
end
