class LotteryActivityTicket < ActiveRecord::Base
  belongs_to :lottery_activity_order

  validates_presence_of :code

  scope :ordered, -> { order("created_at desc") }
end
