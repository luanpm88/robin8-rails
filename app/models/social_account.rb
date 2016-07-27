class SocialAccount < ActiveRecord::Base
  before_save :auto_complete_info
  serialize :others, Hash

  private
  def auto_complete_info
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

end
