class Creation < ActiveRecord::Base

  include Redis::Objects

  hash_key :targets_hash # search condition
    # industries
    # price_from
    # price_to

  STATUS = {
    pending:           '待审核',
    unpassed:          '未通过审核',
    passed:            '通过审核',
    ended:             '活动结束',
    finished:          '活动完成',
    closed:            '关闭'
  }

  ALERTS              = Hash.new('无效的操作')
  ALERTS['passed']    = '审核已通过'
  ALERTS['unpassed']  = '审核已拒绝'

  validates :status, :inclusion => { :in => ["pending", "unpassed", "passed" , "ended", "finished", "closed"] }
  validates_presence_of :name
  validates_length_of :name, maximum: 60, too_long: "输入的值太长"
  validates_length_of :description, maximum: 500, too_long: "输入的值太长"


  has_many :creations_terraces, class_name: "CreationsTerrace"
  has_many :terraces, through: :creations_terraces
  has_many :creation_selected_kols

  belongs_to :user
  belongs_to :trademark

  delegate :name, :description, to: :trademark, prefix: :trademark

  scope :alive,     ->{where.not(status: %w(pending unpassed closed)).order(updated_at: :desc)}
  scope :by_status, ->(status){where(status: status).order(updated_at: :desc)}

  ['pending','unpassed','passed','ended','settled','finished','closed'].each do |value|
    define_method "is_#{value}?" do
      self.status == value
    end
  end

  def is_alive?
    %w(pending unpassed closed).exclude? status
  end

  def brand_name
    "#{user_id}_#{user.smart_name}"
  end

  def time_range
    "#{start_at.strftime('%F')}--#{end_at.strftime('%F')}"
  end

  def price_range
    "¥#{targets_hash[:price_from]}--¥#{targets_hash[:price_to]}"
  end

  def brand_info
    {
      name:       user.smart_name,
      avatar_url: user.avatar_url
    }
  end

end






