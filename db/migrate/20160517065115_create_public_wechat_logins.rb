class CreatePublicWechatLogins < ActiveRecord::Migration
  def change
    create_table :public_wechat_logins do |t|
      t.string :username
      t.string :password_encrypted
      t.text :visitor_cookies
      t.text :redirect_url
      t.string :login_type
      t.text :login_cookies
      t.datetime :login_time
      t.string :ticket
      t.string :appid
      t.string :uuid
      t.string :operation_seq
      t.string :status

      t.timestamps null: false
    end
  end
end
