class AddColumnIsInvitedToInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :is_invited, :boolean, :default => false
  end
end
