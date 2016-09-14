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

  def get_net_income(kol)
    return 0 unless self.lottery_product.income? and kol == self.lucky_kol
    self.lottery_product.price - self.orders.where(kol: self.lucky_kol).sum(:credits)
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

  def deliver
    return if self.delivered
    return unless self.status == "finished"

    if self.lottery_product.mode == "cash"
      self.deliver_cash_product
    end
  end

  def deliver_product
    return if self.delivered
    return unless self.status == "finished"

    unless SmsMessage.where(receiver: self.lucky_kol, resource: self, mode: "lottery_delivery").exists?
      express_str = ""
      if self.express_number.present?
        express_str = "快递：#{self.express_name.presence || '顺丰'}，单号：#{self.express_number}。"
      end

      content = "您在Robin8一元夺宝的商品已发货。#{express_str}晒中奖商品到朋友圈，可以获得5元现金红包，联系客服领取。"
      self.delivery_notify(content)
    end

    self.update(delivered: true, delivered_at: Time.now)
  end

  def deliver_cash_product
    unless Transaction.where(account: self.lucky_kol, item: self, subject: "lottery_reward").exists?
      price = self.lottery_product.price - 1 # temp
      transaction = self.lucky_kol.income(price, "lottery_reward", self)
    end

    unless SmsMessage.where(receiver: self.lucky_kol, resource: self, mode: "lottery_delivery").exists?
      content = "您在Robin8参与的一元夺宝已中奖，现金已发放！"
      self.delivery_notify(content)
    end

    self.update(delivered: true, delivered_at: Time.now)
  end

  def delivery_notify(content)
    SmsMessage.send_by_resource_to(self.lucky_kol, content, self, {mode: "lottery_delivery"})
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
