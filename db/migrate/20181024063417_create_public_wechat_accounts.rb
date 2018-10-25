class CreatePublicWechatAccounts < ActiveRecord::Migration
  def change
    create_table :public_wechat_accounts do |t|
      t.belongs_to :kol
      t.string :nickname
      t.float :price, defalut: 0.0
      t.float :mult_price, defalut: 0.0
      t.float :sub_price, defalut: 0.0
      t.float :n_price, defalut: 0.0
      t.datetime :quote_expired_at
      t.integer :fans_count, default: 0
      t.integer :gender
      t.string :content_show
      t.string :remark
      t.integer :status, default: 0
      t.timestamps null: false
    end
  end
end
