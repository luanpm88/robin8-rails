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

  BIGV_GENDER = {
    1 => 'M',
    2 => 'F'
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

  scope :recent,    ->(_start,_end){ where(created_at: _start.._end) }
  scope :by_status, ->(status){where(status: status)}
  scope :valid,     ->{where(status: 1)}

  after_save :update_kol_role_status, on: [:create, :update]
  after_update :sent_message

  delegate :mobile_number, to: :kol

  def get_dsp
    {1 => '微博大V身份认证已通过', -1 => '微博大V身份认证未通过，请联系客服处理'}[status]
  end

  def bind_bigV(profile_id)
    url = "http://api_admin.robin8.net:8080/api/v1/r1/price/weibo/kol_bind/bind_kol?application_id=local-001&application_key=admin-001&kol_id=#{kol_id}&profile_id=#{profile_id}"

    res = RestClient.post(url, bigV_hash.to_json, :content_type => :json, :accept => :json, :timeout => 30) rescue ""

    if JSON(res)['result'] == "success"
      self.update_attributes(status: 1, profile_id: profile_id)
      self.is_read.set 1
      self.kol.update_column(:role_apply_status, 'passed')
    else
      JSON(res)['error_msg']
    end
  end

  def bigV_hash
    {
      kol_id:       kol_id,
      price:        price,
      cities:       cities.map(&:name),
      tags:         circles.map(&:tags).flatten.uniq.map(&:name),
      fans_count:   fans_count,
      fans_gender:  BIGV_GENDER[gender]
    }
  end

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
