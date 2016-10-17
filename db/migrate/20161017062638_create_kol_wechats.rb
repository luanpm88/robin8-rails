class CreateKolWechats < ActiveRecord::Migration
  def change
    add_column :campaigns, :wechat_auth_type, :string, :default => 'base' # nothing, base, self_info, friends_info

    create_table :kol_wechats do |t|
      t.integer :kol_id
      t.string :openid
      t.string :nickname
      t.integer :sex
      t.string :province
      t.string :city
      t.string :country
      t.string :headimgurl
      t.text   :privilege
      t.string :unionid
      t.string :category # self\friend

      t.timestamps null: false
    end
  end
end
