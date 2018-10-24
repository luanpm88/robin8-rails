class Creator < ActiveRecord::Base

  after_save :update_kol_role_status, :on => [:create, :update]
  
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


  validates_presence_of :kol_id


  AgeRange = {
    "1":    '0-17',
    "2":    '18-24',
    "3":    '25-29',
    "4":    '30-34',
    "5":    '35-39',
    "6":    '40-49',
    "7":    '50-59',
    "8":    '60-'
  }


  private 

  def update_kol_role_status
    self.kol.update_attributes(role_apply_status: 'applying') if self.kol and self.kol.role_apply_status != 'applying'
  end





end
