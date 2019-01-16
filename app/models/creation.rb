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

  validates :status, :inclusion => { :in => ["pending", "unpassed", "passed" , "ended", "finished", "closed"] }
  validates_presence_of :name
  validates_length_of :name, maximum: 60, too_long: "输入的值太长"
  validates_length_of :description, maximum: 500, too_long: "输入的值太长"


  has_many :creations_terraces, class_name: "CreationsTerrace"
  has_many :terraces, through: :creations_terraces
  has_many :creation_selected_kols

  belongs_to :user

  scope :alive,     ->{where.not(status: %w(pending alive)).order(updated_at: :desc)}
  scope :by_status, ->(status){where(status: status).order(updated_at: :desc)}

  ['pending','unpassed','passed','ended','settled','finished','closed'].each do |value|
    define_method "is_#{value}？" do
      self.status == value
    end
  end

end






