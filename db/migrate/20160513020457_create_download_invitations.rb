class CreateDownloadInvitations < ActiveRecord::Migration
  def change
    create_table :download_invitations do |t|
      t.integer :inviter_id
      t.string   "visitor_cookies",  limit: 600
      t.string   "visitor_ip",      limit: 255
      t.boolean   "effective"
      t.text     "visitor_referer", limit: 3555
      t.text     "visitor_agent",   limit: 3555
      t.string   "app_platform"
      t.string   "device_model"
      t.string   "os_version"


      t.timestamps null: false
    end
  end
end
