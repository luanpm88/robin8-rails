class CreateWeiboAccounts < ActiveRecord::Migration
  def change
    create_table :weibo_accounts do |t|
      t.belongs_to :kol
      t.string :nickname
      t.integer :auth_type, default: 1
      t.float :fwd_price, default: 0.0
      t.float :price, default: 0.0
      t.float :live_price, defalut: 0.0
      t.datetime :quote_expired_at
      t.integer :fans_count, defalut: 0 
      t.integer :gender
      t.string :content_show
      t.string :remark
      t.integer :status, default: 0 
      t.timestamps null: false
    end
  end
end
