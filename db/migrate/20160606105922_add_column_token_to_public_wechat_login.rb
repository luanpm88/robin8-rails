class AddColumnTokenToPublicWechatLogin < ActiveRecord::Migration
  def change
    add_column :public_wechat_logins, :token, :string

    change_column :feedbacks, :content, :string, :limit => 1000
  end
end
