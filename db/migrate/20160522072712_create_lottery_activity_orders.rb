class CreateLotteryActivityOrders < ActiveRecord::Migration
  def change
    create_table :lottery_activity_orders do |t|
      t.belongs_to :kol, index: true
      t.belongs_to :lottery_activity, index: true
      t.string :credits
      t.string :lucky_numbers

      t.timestamps null: false
    end
  end
end
