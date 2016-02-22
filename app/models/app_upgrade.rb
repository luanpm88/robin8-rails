class AppUpgrade < ActiveRecord::Base
  scope :Andriod, ->{where(:app_platform => 'Andriod')}
  scope :IOS, -> {where(:app_platform => 'IOS')}

  def self.newest_version(platform)
    self.send(platform).order("app_version desc").first
  end

  def self.check(platform,version)
    newest_version = self.newest_version(platform)
    if newest_version.app_version > version
      return  [true,newest_version]
    else
      return [false, nil]
    end
  end

end
