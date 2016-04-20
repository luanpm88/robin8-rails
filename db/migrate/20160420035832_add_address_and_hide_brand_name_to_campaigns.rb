class AddAddressAndHideBrandNameToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :address, :string
    add_column :campaigns, :hide_brand_name, :boolean, default: false
  end
end
