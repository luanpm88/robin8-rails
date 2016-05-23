class CreateLotteryActivities < ActiveRecord::Migration
  def change
    create_table :lottery_activities do |t|
      t.string :name
      t.string :description
      t.string :total_number
      t.string :actual_number
      t.string :lucky_number
      t.string :status, default: 'pending'

      t.timestamps null: false
    end
  end
end
