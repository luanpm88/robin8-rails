class ChangeTalkingDataCampaignColums < ActiveRecord::Migration
  def change
    remove_column :kols, :talkingdata_channel_id
    add_column :kols, :talkingdata_promotion_name, :string
  end
end
