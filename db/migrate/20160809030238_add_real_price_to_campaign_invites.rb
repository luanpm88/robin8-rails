class AddRealPriceToCampaignInvites < ActiveRecord::Migration
  def change
    rename_column :campaign_invites, :budget, :sale_price
    add_column :campaign_invites, :price, :float
  end
end
