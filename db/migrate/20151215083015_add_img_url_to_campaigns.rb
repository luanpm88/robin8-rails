class AddImgUrlToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :img_url, :string
  end
end
