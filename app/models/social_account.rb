class SocialAccount < ActiveRecord::Base
  has_many :social_account_tags
  has_many :tags, :through => :social_account_tags, :source => :tag
  belongs_to :kol

  # validates :homepage, :presence => {message: "主页不能为空"}
  before_create :auto_complete_info
  after_create :create_kol_shows
  serialize :others, Hash
  mount_uploader :screenshot, ImageUploader

  Providers = {"wechat" => "微信", "public_wechat" => '公众号', "qq" => 'QQ', "weibo" => "微博", "meipai" => "美拍", "miaopai" => "秒拍",
               "zhihu" => '知乎', "douyu" => '斗鱼', "yingke" => "映客", "tieba" => '贴吧', "tianya" => "天涯", "taobao" => "淘宝",
               "huajiao" => "花椒", "nice" => "NICE", "douban" => "豆瓣", "xiaohongshu" => "小红书", "yizhibo" => '一直播',
               "meila" => "美啦", "other" => "其它" }

  scope :wechat, -> {where(provider: 'wechat')}

  def get_weibo_homepage
    return if self.homepage.blank?
    uid = self.homepage.split("/").last.split("?").first
    if uid.match(/^\d+$/).present?
      homepage = "http://m.weibo.cn/u/#{uid}"
    else
      homepage = "http://m.weibo.cn/d/#{uid}"
    end
    homepage
  end

  def sale_price
    return 0 if self.price.to_i.zero?

    (((self.price.to_i * 1.3)/10).to_i + 1) * 10
  end

  def provider_text
    Providers[self.provider]
  end

  def auto_complete_info
    return if self.homepage.blank?
    homepage = self.homepage.gsub("https://", "http://")
    if self.provider == 'weibo'
      puts  "======#{get_weibo_homepage}"
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
    return if self.homepage.blank?  && self.provider != 'public_wechat'
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
    AgentKol.delete_all
    KolShow.delete_all
    KolKeyword.delete_all
    SocialAccount.delete_all
    SocialAccountTag.delete_all
    big_v_ids =  Kol.where(:kol_role => 'mcn_big_v').collect{|t| t.id}
    KolTag.where(:kol_id =>big_v_ids ).delete_all
    Kol.where(:kol_role => 'mcn_big_v').delete_all
  end

end
