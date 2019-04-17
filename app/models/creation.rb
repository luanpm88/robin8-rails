class Creation < ActiveRecord::Base

  include Redis::Objects
  include Creations::MessageHelper

  hash_key :targets_hash # search condition
    # industries
    # price_from
    # price_to
  value :reject_reason

  STATUS = {
    pending:           '待审核',
    unpassed:          '未通过审核',
    passed:            '通过审核',
    ended:             '活动结束',
    closed:            '关闭'
  }

  ALERTS              = Hash.new('无效的操作')
  ALERTS['passed']    = '审核已通过'
  ALERTS['unpassed']  = '审核已拒绝'

  validates :status, :inclusion => { :in => STATUS.keys.collect{|ele| ele.to_s} }
  validates_presence_of :name
  validates_length_of :name, maximum: 60, too_long: "输入的值太长"
  validates_length_of :description, maximum: 500, too_long: "输入的值太长"


  has_many :creations_terraces, class_name: "CreationsTerrace"
  has_many :terraces, through: :creations_terraces
  has_many :creation_selected_kols
  has_many :tenders

  belongs_to :user
  belongs_to :trademark

  delegate :name, :description, to: :trademark, prefix: :trademark

  scope :recent,    ->(_start,_end){ where(created_at: _start.._end) }
  scope :alive,     ->{where.not(status: %w(pending unpassed closed)).order(id: :desc)}
  scope :by_status, ->(status){where(status: status).order(updated_at: :desc)}

  STATUS.keys.each do |value|
    define_method "is_#{value}?" do
      self.status == value.to_s
    end
  end

  def is_alive?
    %w(pending unpassed closed).exclude? status
  end

  def brand_name
    "#{user_id}_#{user.smart_name}"
  end

  def time_range
    "#{start_at.strftime('%Y-%m-%d %H:%M:%S')}--#{end_at.strftime('%Y-%m-%d %H:%M:%S')}"
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

  def can_edit?
    ['pending', 'unpassed'].include?(self.status) ? true : false
  end

  def can_finish?
    self.creation_selected_kols.map(&:status) - %w(preelect pending finished rejected) == []
  end

  def can_ended?
    self.update_attributes(status: :ended) if self.end_at < Time.now && self.can_finish?
  end

end






