class LotteryActivity < ActiveRecord::Base
  has_many :lottery_activity_orders
  has_many :kols, through: :lottery_activity_orders
  has_many :pictures, as: :imageable
end
