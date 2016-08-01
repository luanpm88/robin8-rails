class SocialAccount < ActiveRecord::Base
  has_many :social_account_professions
  has_many :professions, :through => :social_account_professions, :source => :profession

  before_save :auto_complete_info
  after_create :create_kol_shows
  serialize :others, Hash

  private
  def auto_complete_info
    return if self.followers_count.present?
    homepage = self.homepage.gsub("https://", "http://")
    if self.provider == 'weibo'
      homepage = homepage.gsub("weibo.com", 'm.weibo.cn')
      info = Crawler::Weibo.get_content(homepage)
    elsif self.provider == 'meipai'
      info = Crawler::Meipai.get_content(homepage)
    elsif self.provider == 'miaopai'
      info = Crawler::Miaopai.get_content(homepage)
    else
      info = {}
    end
    self.attributes = info
  end


  def create_kol_shows
    homepage = self.homepage.gsub("https://", "http://")
    if self.provider == 'weibo'
      homepage = homepage.gsub("weibo.com", 'm.weibo.cn')
      Crawler::Weibo.create_kol_info(self)
    elsif self.provider == 'meipai'
      Crawler::Meipai.create_kol_info(self)
    elsif self.provider == 'miaopai'

    else
    end
  end

end
