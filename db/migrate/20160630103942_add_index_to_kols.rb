class AddIndexToKols < ActiveRecord::Migration
  def change
    change_column :kols, :device_token, :string, :limit => 80

    add_index :kols, :device_token
    add_index :kols, :forbid_campaign_time
    add_index :kols, :updated_at
  end
end
