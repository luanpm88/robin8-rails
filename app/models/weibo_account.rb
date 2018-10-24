class WeiboAccount < ActiveRecord::Base
  # fwd_price:        转发价格
  # price:            直发价格
  # live_price:       直播价格
  # quote_expired_at: 报价有效期

  AuthTypes = {
    1 => '未认证',
    2 => '个人认证', 
    3 => '机构认证'
  }

  validates_presence_of :kol_id
  
  belongs_to :kol

  # cirlces 自媒体圈子
  has_many :weibo_accounts_circles, class_name: "WeiboAccountsCircle"
  has_many :circles, through: :weibo_accounts_circles

  # 城市
  has_many :weibo_accounts_cities, class_name: "WeiboAccountsCity"
  has_many :cities, through: :weibo_accounts_cities

  after_save :update_kol_role_status, on: [:create, :update]

  private 

  def update_kol_role_status
    kol.update_attributes(role_apply_status: 'applying') if kol.role_apply_status != 'applying'
  end



end
