class Creation < ActiveRecord::Base

  include Redis::Objects

  hash_key :targets_hash # search condition

  STATUS = {
    pending:           '待审核',
    unpassed:          '未通过审核',
    passed:            '通过审核',
    ended:             '活动结束',
    finished:          '活动完成',
    closed:            '关闭'
  }

  # mount_uploader :image, ImageUploader

  validates :status, :inclusion => { :in => ["pending", "unpassed", "passed" , "ended", "finished", "closed"] }
  validates_presence_of :name 

  has_many :creations_terraces, class_name: "CreationsTerrace"
  has_many :terraces, through: :creations_terraces

  belongs_to :user

  ['pending','unpassed','passed','ended','settled','finished','closed'].each do |value|
    define_method "is_#{value}_status?" do
      self.status == value
    end
  end

end






