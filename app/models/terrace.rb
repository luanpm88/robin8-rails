#自媒体平台
class Terrace < ActiveRecord::Base
  
  validates :name, :short_name, presence:   {message: '不能为空'}
  validates :name, :short_name, uniqueness: {message: '已被占用'}

  mount_uploader :avatar, ImageUploader

	#creator
  has_many :creators_terraces, class_name: "CreatorsTerrace"
  has_many :creators, through: :creators_terraces

end
