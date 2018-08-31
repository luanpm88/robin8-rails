class AddAdminUserIdToEWalletAccounts < ActiveRecord::Migration
  def change
  	add_column :e_wallet_accounts, :admin_user_id, :integer
  end
end
