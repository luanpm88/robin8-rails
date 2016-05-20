class CreatePublicWechatIdentities < ActiveRecord::Migration
  def change
    create_table :public_wechat_identities do |t|
      t.integer :kol_id
      t.string :email
      t.string :password_encrypted
      t.string :nick_name
      t.string :logo_url
      t.string :user_name


      t.timestamps null: false
    end
  end
end
