class AddDeclineDateToInterestedCampaigns < ActiveRecord::Migration
  def change
    add_column :interested_campaigns, :decline_date, :datetime
  end
end
