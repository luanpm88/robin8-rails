class LotteryActivityOrder < ActiveRecord::Base
  belongs_to :kol
  belongs_to :lottery_activity
end
