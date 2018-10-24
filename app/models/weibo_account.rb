class WeiboAccount < ActiveRecord::Base
  belongs_to :kol

  #cirlces 自媒体圈子
  has_many :weibo_accounts_circles, class_name: "WeiboAccountsCircle"
  has_many :circles, through: :weibo_accounts_circles

  #城市
  has_many :weibo_accounts_cities, class_name: "WeiboAccountsCity"
  has_many :cities, through: :weibo_accounts_cities

  #auth_type 认证类型
  #未认证： 1， 个人认证： 2， 机构认证： 3

  #gender 男： 1， 女： 2

  #status: 0, 1, -1

  #fwd_price 转发价格
  #price 直发价格
  #live_price 直播价格
  #quote_expired_at 报价有效期



end
