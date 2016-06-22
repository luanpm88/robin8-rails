class AddRevokeTimeToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :revoke_time, :datetime
  end
end
