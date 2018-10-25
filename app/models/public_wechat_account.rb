class PublicWechatAccount < ActiveRecord::Base
  # price      单图文
  # mult_price 多图文头条
  # sub_price  次条
  # n_price    n条

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

  after_save :update_kol_role_status, on: [:create, :update]

  private 

  def update_kol_role_status
    kol.update_attributes(role_apply_status: 'applying') if kol.role_apply_status != 'applying'
    self.update_column(:status, 0)
  end  


end
