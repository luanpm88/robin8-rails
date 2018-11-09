class CreatePublicWechatAccountsCities < ActiveRecord::Migration
  def change
    create_table :public_wechat_accounts_cities do |t|
      t.belongs_to :public_wechat_account
      t.belongs_to :city
      t.timestamps null: false
    end
  end
end
