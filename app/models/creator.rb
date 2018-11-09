class Creator < ActiveRecord::Base

  include Redis::Objects

  counter :is_read

  AgeRanges = {
    1 => '0-17',
    2 => '18-24',
    3 => '25-29',
    4 => '30-34',
    5 => '35-39',
    6 => '40-49',
    7 => '50-59',
    8 => '60-'
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

  #cirlces 自媒体圈子
  has_many :creators_circles, class_name: "CreatorsCircle"
  has_many :circles, through: :creators_circles

  #terrace 自媒体平台
  has_many :creators_terraces, class_name: "CreatorsTerrace"
  has_many :terraces, through: :creators_terraces

  #城市
  has_many :creators_cities, class_name: "CreatorsCity"
  has_many :cities, through: :creators_cities
  
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
      Message.new_role_notice_message(self.kol, 'passed', 'creator')
    elsif self.status_changed? && self.status == -1
      Message.new_role_notice_message(self.kol, 'rejected', 'creator')
    end
  end

end
