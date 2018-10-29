# encoding: utf-8

class City < ActiveRecord::Base

  belongs_to :province
  has_many :districts, dependent: :destroy

  #creator
  has_many :creators_cities, class_name: "CreatorsCity"
  has_many :creators, through: :creators_cities

  #weiboaccount
  has_many :weibo_accounts_cities, class_name: "WeiboAccountsCity"
  has_many :weibo_accounts, through: :weibao_accounts_cities

  #publicwechataccount
  has_many :public_wechat_accounts_cities, class_name: "PublicWechatAccountsCity"
  has_many :public_wechat_accounts, through: :public_wechat_accounts_cities

  scope :with_province, ->(province) { where(province_id: province) }

  def short_name
    @short_name ||= name.gsub(/市|自治州|地区|特别行政区/, '')
  end

  def siblings
    @siblings ||= where(nil).with_province(self.province_id)
  end

  def show_name
    name.gsub(/市/, '')
  end

end
