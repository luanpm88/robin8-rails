class AddModeToLotteryActivity < ActiveRecord::Migration
  def change
    add_column :lottery_products, :mode, :string
  end
end
