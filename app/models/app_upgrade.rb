class AppUpgrade < ActiveRecord::Base
  scope :Andriod, ->{where(:app_platform => 'Andriod')}
  scope :Android, ->{where(:app_platform => 'Android')}
  scope :IOS, -> {where(:app_platform => 'IOS')}
  validates_uniqueness_of :app_version, :scope => [:app_platform]

  def self.newest_version(platform)
    # fix v1 spell wrong
    if platform == 'Andriod'
      self.send('Android').order("app_version desc").first
    else
      self.send(platform).order("app_version desc").first
    end
  end

  def self.check(platform,version)
    newest_version = self.newest_version(platform)
    if newest_version.app_version > version
      return  [true,newest_version]
    else
      return [false, nil]
    end
  end

  def self.ios_last
    self.IOS.last.app_version
  end

end
