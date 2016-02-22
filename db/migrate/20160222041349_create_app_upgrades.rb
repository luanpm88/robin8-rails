class CreateAppUpgrades < ActiveRecord::Migration
  def change
    create_table :app_upgrades do |t|
      t.string :app_platform
      t.string :app_version
      t.datetime :release_at
      t.string :release_note
      t.string :download_url
      t.boolean :force_upgrade

      t.timestamps null: false
    end
  end
end
