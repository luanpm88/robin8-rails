class AddSubTypeToCampaignInvite < ActiveRecord::Migration
  def change
  	add_column :campaign_invites , :sub_type ,:string
  end
end
