class AddAlipayNotifyTextToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :alipay_notify_text, :text
  end
end
