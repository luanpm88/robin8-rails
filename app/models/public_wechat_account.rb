class PublicWechatAccount < ActiveRecord::Base
  belongs_to :kol

  #cirlces 自媒体圈子
  has_many :public_wechat_accounts_circles, class_name: "PublicWechatAccountsCircle"
  has_many :circles, through: :public_wechat_accounts_circles

  #城市
  has_many :public_wechat_accounts_cities, class_name: "PublicWechatAccountsCity"
  has_many :cities, through: :public_wechat_accounts_cities


  #price 单图文
  #mult_price 多图文头条
  #sub_price 次条
  #n_price n条
  


end
