class AddContentTypeAndConCashOptionToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :content_type, :string
    add_column :campaigns, :non_cash, :boolean, :default => false
  end
end
