class ChangeLotteryActivities < ActiveRecord::Migration
  def change
    create_table :lottery_activity_tickets do |t|
      t.belongs_to :lottery_activity_order, index: true
      t.string :code, index: true
    end

    change_column :lottery_activities, :total_number, :integer
    change_column :lottery_activities, :actual_number, :integer

    add_column    :lottery_activities, :lucky_kol_id, :integer
    add_column    :lottery_activities, :code, :string
    add_column    :lottery_activities, :draw_at, :datetime
    add_column    :lottery_activities, :published_at, :datetime

    if column_exists? :lottery_activity_orders, :lucky_numbers
      remove_column :lottery_activity_orders, :lucky_numbers
    end

    change_column :lottery_activity_orders, :credits, :integer
    add_column    :lottery_activity_orders, :code, :string
    add_column    :lottery_activity_orders, :number, :integer, default: 0
    add_column    :lottery_activity_orders, :status, :string, default: 'pending'

    add_column    :pictures, :type, :string
  end
end
