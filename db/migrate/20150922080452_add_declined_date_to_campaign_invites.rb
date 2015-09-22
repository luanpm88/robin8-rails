class AddDeclinedDateToCampaignInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :decline_date, :date
  end
end
