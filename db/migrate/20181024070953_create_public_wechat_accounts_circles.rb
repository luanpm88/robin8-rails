class CreatePublicWechatAccountsCircles < ActiveRecord::Migration
  def change
    create_table :public_wechat_accounts_circles do |t|
      t.belongs_to :public_wechat_account
      t.belongs_to :circle
      t.timestamps null: false
    end
  end
end
