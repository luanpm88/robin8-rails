class AddCampaignInvitesCountToStasticData < ActiveRecord::Migration
  def change
    add_column :stastic_data, :campaign_invites_count, :integer
  end
end
