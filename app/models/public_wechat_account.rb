class PublicWechatAccount < ActiveRecord::Base
  # price      单图文
  # mult_price 多图文头条
  # sub_price  次条
  # n_price    n条

  include Redis::Objects
  
  counter :is_read

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
  has_many :public_wechat_accounts_circles, class_name: "PublicWechatAccountsCircle"
  has_many :circles, through: :public_wechat_accounts_circles

  # 城市
  has_many :public_wechat_accounts_cities, class_name: "PublicWechatAccountsCity"
  has_many :cities, through: :public_wechat_accounts_cities

  scope :recent,    ->(_start,_end){ where(created_at: _start.beginning_of_day.._end.end_of_day) }
  scope :by_status, ->(status){where(status: status)}
  scope :valid,     ->{where(status: 1)}

  after_save :update_kol_role_status, on: [:create, :update]
  after_update :sent_message

  delegate :mobile_number, to: :kol

  def get_dsp
    {1 => '微信公众号大V身份认证已通过', -1 => '微信公众号大V身份认证未通过，请联系客服处理'}[status]
  end

  private 

  def update_kol_role_status
    kol.update_attributes(role_apply_status: 'applying') if kol.role_apply_status != 'applying'
    self.update_column(:status, 0)
  end
  
  def sent_message
    if self.status_changed? && self.status == 1
      Message.new_role_notice_message(self.kol, 'passed', 'public_wechat_account')
    elsif self.status_changed? && self.status == -1
      Message.new_role_notice_message(self.kol, 'rejected', 'public_wechat_account')
    end
  end

end
