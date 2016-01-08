class AddColumnReceiveCampaignTimeAndClickThresholdToKol < ActiveRecord::Migration
  def change
    add_column :kols, :forbid_campaign_time, :datetime
    add_column :kols, :click_threshold, :integer
  end
end
