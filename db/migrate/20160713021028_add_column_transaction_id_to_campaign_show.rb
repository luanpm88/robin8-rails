class AddColumnTransactionIdToCampaignShow < ActiveRecord::Migration
  def change
    add_column :campaign_shows, :transaction_id, :integer
  end
end
