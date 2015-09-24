class AddKolSocialFields < ActiveRecord::Migration
  def change
    add_column :kols, :wechat_personal_fans, :integer
    add_column :kols, :wechat_public_name, :string
    add_column :kols, :wechat_public_id, :string
    add_column :kols, :wechat_public_fans, :integer
  end
end
