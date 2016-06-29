class LotteryActivity < ActiveRecord::Base
  include Redis::Objects

  lock :allocate, :expiration => 10  # sec
  set  :ticket_bucket

  has_many :orders, class_name: LotteryActivityOrder.to_s, dependent: :destroy
  has_many :kols, through: :orders
  has_many :tickets, through: :orders, source: :tickets

  belongs_to :lucky_kol, class_name: Kol.to_s
  belongs_to :lottery_product, class_name: LotteryProduct.to_s

  validates_numericality_of :total_number, greater_than_or_equal_to: 1
  validates_inclusion_of :status, :in => %w( pending executing drawing finished )

  after_initialize :assign_default_values, unless: :persisted?
  after_create :generate_ticket_bucket

  scope :executing, -> { where("status = ? and published_at <= ?", "executing", Time.now) }
  scope :available, -> { where.not(status: [ "pending" ]) }
  scope :delivered, -> { where(delivered: true) }
  scope :ordered, -> { order("created_at desc") }


  def generate_ticket_bucket
    bucket = []

    # build a set in redis containing all possible ticket numbers
    (1..self.total_number).each do |n|
      bucket << 10000000 + n
    end

    self.ticket_bucket.add bucket
  end

  def generate_lucky_number(salt) # salt = A + B
    (salt / total_number) % total_number + 10000001
  end

  def try_draw
    return false if self.avail_number > 0
    self.draw!
  end

  def draw!
    self.update(status: "drawing")
    LotteryDrawWorker.perform_async(self.code)
  end

  def allocate(size)
    # pop (size) random tickets from bucket, only using new version redis (>= 3.20)
    # return self.ticket_bucket.spop(size)

    self.allocate_lock.lock do
      tickets = self.ticket_bucket.randmember(size)
      raise "活动剩余人次不足" if tickets.size != size

      self.ticket_bucket.delete(tickets)
      tickets
    end
  end

  def avail_number
    self.ticket_bucket.count
  end

  def actual_number
    self.total_number - self.avail_number
  end

  def enough_tickets?(size)
    self.avail_number>= size
  end

  def token_number(kol)
    self.orders.paid.where(kol: kol).sum(:number)
  end

  def token_ticket_codes(kol)
    self.orders.paid.where(kol: kol).inject([]) do |res, o|
      res += o.tickets
    end.map(&:code)
  end

  def poster
    self.posters.first
  end

  def status_text
    LotteryActivity.i18t_status self.status
  end

  def self.i18t_status(s)
    case s
    when "executing"
      "执行中"
    when "finished"
      "已完成"
    when "drawing"
      "开奖中"
    when "pending"
      "待发布"
    end
  end

private

  def assign_default_values
    self.published_at ||= Time.now
    self.code = loop do
      c = '30%06d' % rand(6 ** 6)
      break c unless self.class.exists?(code: c)
    end unless self.code
  end
end
