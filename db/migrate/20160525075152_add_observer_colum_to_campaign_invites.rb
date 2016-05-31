class AddObserverColumToCampaignInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :observer_status, :integer, default: 0 
    add_column :campaign_invites, :observer_text,    :text
  end
end
