class AddPartnerSettleToCampaignInvite < ActiveRecord::Migration
  def change
  	add_column :campaign_invites, :partners_settle, :float
  end
end
