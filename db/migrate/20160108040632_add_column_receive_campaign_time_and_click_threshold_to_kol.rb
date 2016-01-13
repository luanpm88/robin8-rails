class AddColumnReceiveCampaignTimeAndClickThresholdToKol < ActiveRecord::Migration
  def change
    add_column :kols, :forbid_campaign_time, :datetime
    add_column :kols, :five_click_threshold, :integer
    add_column :kols, :total_click_threshold, :integer
  end
end
