class UpdateAppUpgradeAndroidPlatform < ActiveRecord::Migration
  def change
    AppUpgrade.where(:app_platform => 'Andriod').update_all(:app_platform => 'Android')
  end
end
