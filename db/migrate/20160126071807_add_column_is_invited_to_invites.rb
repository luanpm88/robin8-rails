class AddColumnIsInvitedToInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :is_invited, :boolean, :default => false
    add_column :campaign_invites, :share_count, :integer, :default => 0
  end
end
