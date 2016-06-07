class CreateLotteryProducts < ActiveRecord::Migration
  def change
    create_table :lottery_products do |t|
      t.string  :name
      t.string  :description
      t.string  :cover
      t.integer :quantity, default: 1
      t.integer :price, default: 0

      t.timestamps null: false
    end

    add_column  :lottery_activities, :lottery_product_id, :integer

    LotteryActivity.all.each do |activity|
      product = LotteryProduct.where(name: activity.name).first_or_create(
        description: activity.description,
        price: activity.total_number
      )
      activity.update(lottery_product: product)
    end
  end
end
