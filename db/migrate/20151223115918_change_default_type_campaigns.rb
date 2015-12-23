class ChangeDefaultTypeCampaigns < ActiveRecord::Migration
  def change
    change_column :campaigns, :url, :text
  end
end
