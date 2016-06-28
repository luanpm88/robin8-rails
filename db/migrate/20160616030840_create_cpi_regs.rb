class CreateCpiRegs < ActiveRecord::Migration
  def change
    create_table :cpi_regs do |t|
      t.string :appid
      t.string :reg_ip
      t.string :bundle_name
      t.string :app_platform
      t.string :app_version
      t.string :os_version
      t.string :device_model

      t.integer :campaign_show_id
      t.string :status, :default => 'pending'

      t.timestamps null: false
    end
  end
end
