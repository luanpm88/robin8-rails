class AddKolIdToPublicWechatLogin < ActiveRecord::Migration
  def change
    add_column :public_wechat_logins, :kol_id, :integer
    add_index :public_wechat_logins, :kol_id
  end
end
