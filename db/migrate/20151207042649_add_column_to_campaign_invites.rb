class AddColumnToCampaignInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :uuid, :string
    add_column :campaign_invites, :share_url, :string
    add_column :campaign_invites, :total_click, :integer , :default => 0
    add_column :campaign_invites, :avail_click, :integer , :default => 0

    # add_index :campaign_invites, :uuid, unique: true, name: 'uuid'
  end
end
