#自媒体平台
class Terrace < ActiveRecord::Base
  #creator
  has_many :creators_terraces, class_name: "CreatorsTerrace"
  has_many :creators, through: :creators_terraces

  mount_uploader :avatar, ImageUploader
  
end
