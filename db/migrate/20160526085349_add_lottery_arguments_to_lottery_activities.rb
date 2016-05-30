class AddLotteryArgumentsToLotteryActivities < ActiveRecord::Migration
  def change
    add_column    :lottery_activities, :order_sum, :string
    add_column    :lottery_activities, :lottery_number, :string
    add_column    :lottery_activities, :lottery_issue, :string
  end
end
