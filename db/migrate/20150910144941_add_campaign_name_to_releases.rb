class AddCampaignNameToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :campaign_name, :string
  end
end
