class AddAdminDescToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :admin_desc, :string
  end
end
