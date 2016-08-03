class SocialAccount < ActiveRecord::Base
  has_many :social_account_professions
  has_many :professions, :through => :social_account_professions, :source => :profession

  before_save :auto_complete_info
  after_create :create_kol_shows
  serialize :others, Hash

  def get_weibo_homepage
    uid = self.homepage.split("/").last.split("?").first
    if uid.match(/^\d+$/).present?
      homepage = "http://m.weibo.cn/u/#{uid}"
    else
      homepage = "http://m.weibo.cn/d/#{uid}"
    end
    homepage
  end

  def sale_price
    (((self.price.to_i * 1.3)/10).to_i + 1) * 10
  end

  def provider_text
    case self.provider
    when "weibo"
      "微博"
    when "public_wechat"
      "微信公众号"
    when "meipai"
      "美拍"
    when "miaopai"
      "秒拍"
    end
  end

  private
  def auto_complete_info
    return if self.followers_count.present?
    homepage = self.homepage.gsub("https://", "http://")
    if self.provider == 'weibo'
      info = Crawler::Weibo.get_content(get_weibo_homepage)
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
    if self.provider == 'weibo'
      Crawler::Weibo.create_kol_info(self)
    elsif self.provider == 'meipai'
      Crawler::Meipai.create_kol_info(self)
    elsif self.provider == 'miaopai'
      Crawler::Miaopai.create_kol_info(self)
    elsif self.provider == 'public_wechat'
      Crawler::PublicWechat.create_kol_info(self)
    end
  end


  def self.clear_data
    return if Rails.env.production?
    Kol.where(:kol_role => 'mcn_big_v').delete_all
    KolShow.delete_all
    KolKeyword.delete_all
    SocialAccount.delete_all
    SocialAccountProfession.delete_all
    KolProfession.delete_all
  end

end
