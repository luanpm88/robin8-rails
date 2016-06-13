class AddTradeNumberToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :trade_number, :string
    add_column :campaigns, :alipay_status, :integer, :default => 0
  end
end
