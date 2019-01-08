class Creation < ActiveRecord::Base

  include Redis::Objects

  hash_key :targets # search condition

  STATUS = {
    pending:           '待审核',
    unpassed:          '未通过审核',
    passed:            '通过审核',
    ended:             '活动结束',
    finished:          '活动完成',
    closed:            '关闭'
  }

  mount_uploader :image, ImageUploader


  has_many :creations_terraces, class_name: "CreationsTerrace"
  has_many :terraces, through: :creations_terraces

  belongs_to :user

end






