class AddValidDaysCountToPromotion < ActiveRecord::Migration
  def change
    add_column :promotions, :valid_days_count, :integer, default: 0
  end
end
