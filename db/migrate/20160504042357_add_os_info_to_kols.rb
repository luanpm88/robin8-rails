class AddOsInfoToKols < ActiveRecord::Migration
  def change
    add_column :kols, :os_version, :string
    add_column :kols, :device_model, :string
  end
end
