class AddColumnAppInfoToKols < ActiveRecord::Migration
  def change
    add_column :kols, :app_platform, :string
    add_column :kols, :app_version, :string
    add_column :kols, :private_token, :string
    add_column :kols, :device_token, :string

    add_column :kols, :desc, :string
    rename_column :kols, :avatar_url, :avatar
    add_column :kols, :alipay_account, :string
    add_column :kols, :name, :string
    add_column :kols, :app_country, :string
    add_column :kols, :app_province, :string
    add_column :kols, :app_city, :string
  end
end
