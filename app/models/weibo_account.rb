class WeiboAccount < ActiveRecord::Base
  # fwd_price:        转发价格
  # price:            直发价格
  # live_price:       直播价格
  # quote_expired_at: 报价有效期

  include Redis::Objects
  
  counter :is_read

  AuthTypes = {
    1 => '未认证',
    2 => '个人认证', 
    3 => '机构认证'
  }

  STATUS = {
    0 => '未审核',
    1 => '审核通过', 
    -1 => '审核拒绝'
  }

  GENDER = {
    1 => '男',
    2 => '女'
  }

  validates :kol_id, presence:   {message: '不能为空'}
  validates :kol_id, uniqueness: {message: '已被占用'}
  
  belongs_to :kol

  # cirlces 自媒体圈子
  has_many :weibo_accounts_circles, class_name: "WeiboAccountsCircle"
  has_many :circles, through: :weibo_accounts_circles

  # 城市
  has_many :weibo_accounts_cities, class_name: "WeiboAccountsCity"
  has_many :cities, through: :weibo_accounts_cities

  after_save :update_kol_role_status, on: [:create, :update]
  after_update :sent_message

  delegate :mobile_number, to: :kol

  private 

  def update_kol_role_status
    kol.update_attributes(role_apply_status: 'applying') if kol.role_apply_status != 'applying'
    self.update_column(:status, 0)
  end

  def sent_message
    if self.status_changed? && self.status == 1
      Message.new_role_notice_message(self.kol, 'passed', 'weibo_account')
    elsif self.status_changed? && self.status == -1
      Message.new_role_notice_message(self.kol, 'rejected', 'weibo_account')
    end
  end



end
