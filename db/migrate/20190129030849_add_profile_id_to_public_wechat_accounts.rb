class AddProfileIdToPublicWechatAccounts < ActiveRecord::Migration
  def change
    add_column :public_wechat_accounts, :profile_id, :string
  end
end
