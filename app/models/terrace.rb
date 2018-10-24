#自媒体平台
class Terrace < ActiveRecord::Base
  #creator
  has_many :creators_terraces, class_name: "CreatorsTerrace"
  has_many :creators, through: :creators_terraces

  validates_presence_of :name, message: '平台名字不能为空'
  validates_uniqueness_of :name, message: '平台名字已被占用'
  validates_presence_of :name, message: '平台英文名不能为空'
  validates_uniqueness_of :name, message: '平台英文名已被占用'

  mount_uploader :avatar, ImageUploader



end
