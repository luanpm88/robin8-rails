class AddColumnAppInfoToKols < ActiveRecord::Migration
  def change
    add_column :kols, :app_platform, :string
    add_column :kols, :app_version, :string
    add_column :kols, :private_token, :string
    add_column :kols, :device_token, :string
  end
end
