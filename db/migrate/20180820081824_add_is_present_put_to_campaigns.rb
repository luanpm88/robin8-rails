class AddIsPresentPutToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :is_present_put, :boolean, default: false
  end
end
