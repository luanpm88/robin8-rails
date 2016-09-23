class AddWithdrawIdToAlipayAccountBlackList < ActiveRecord::Migration
  def change
    add_column :alipay_account_blacklists, :withdraw_id, :integer
  end
end
