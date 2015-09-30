class AddReleaseIdToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :release_id, :integer
  end
end
