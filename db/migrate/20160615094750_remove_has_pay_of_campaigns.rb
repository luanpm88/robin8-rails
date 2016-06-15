class RemoveHasPayOfCampaigns < ActiveRecord::Migration
  def change
    remove_column :campaigns, :has_pay
  end
end
