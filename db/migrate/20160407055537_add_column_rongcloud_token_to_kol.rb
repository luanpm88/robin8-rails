class AddColumnRongcloudTokenToKol < ActiveRecord::Migration
  def change
    add_column :kols, :rongcloud_token, :string
  end
end
