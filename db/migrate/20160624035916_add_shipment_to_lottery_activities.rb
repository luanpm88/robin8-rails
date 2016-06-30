class AddShipmentToLotteryActivities < ActiveRecord::Migration
  def change
    add_column :lottery_activities, :express_number, :string
    add_column :lottery_activities, :express_name, :string
    add_column :lottery_activities, :delivered_at, :datetime
    add_column :lottery_activities, :delivered, :boolean, default: false
  end
end
