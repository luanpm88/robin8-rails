class Creator < ActiveRecord::Base
  
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

end
