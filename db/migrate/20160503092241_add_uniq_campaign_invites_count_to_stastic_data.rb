class AddUniqCampaignInvitesCountToStasticData < ActiveRecord::Migration
  def change
    add_column :stastic_data, :uniq_campaign_invites_count, :integer
  end
end
