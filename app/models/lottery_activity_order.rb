class LotteryActivityOrder < ActiveRecord::Base
  belongs_to :kol
  belongs_to :lottery_activity

  has_many   :tickets, class_name: LotteryActivityTicket.to_s, dependent: :destroy

  validates_presence_of  :kol, :lottery_activity, :credits
  validates_inclusion_of :status, :in => %w( pending paid closed )
  validates_numericality_of :number, greater_than_or_equal_to: 0

  after_initialize :assign_default_values, unless: :persisted?

  scope :paid,    -> { where("status = ?", "paid") }
  scope :pending, -> { where("status = ?", "pending") }
  scope :ordered, -> { order("created_at desc") }

  def checkout
    self.kol.with_lock do
      raise "抱歉，账户余额不足" unless self.kol.can_pay?(self.credits)
      @ticket_set = self.lottery_activity.allocate(self.number)

      self.kol.payout(self.credits, "lettory_activity", self)
    end

    @ticket_set.each do |ticket|
      self.tickets.create(code: ticket)
    end
    self.status = "paid"
    self.save!

    self.lottery_activity.try_draw
  end

private

  def assign_default_values
    self.status = "pending" if self.status.nil?
    self.code = loop do
      c = '10%08d' % rand(10 **8)
      break c unless self.class.exists?(code: c)
    end unless self.code
  end
end
