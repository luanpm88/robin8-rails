class Circle < ActiveRecord::Base
  #tags
  has_many :tags_circles, class_name: "TagsCircle"
  has_many :tags, through: :tags_circles

  #kols
  has_many :kols_circles, class_name: "KolsCircle"
  has_many :kols, through: :kols_circles

  #weiboaccount
  has_many :weibo_accounts_circles, class_name: "WeibaoAccountsCircle"
  has_many :weibo_accounts, through: :weibao_accounts_circles

  #public_wechat_account
  has_many :public_wechat_accounts_circles, class_name: "PublicWhchatAccountsCircle"
  has_many :public_wechat_accounts, through: :public_wechat_accounts_circles

end
