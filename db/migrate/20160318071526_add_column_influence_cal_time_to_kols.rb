class AddColumnInfluenceCalTimeToKols < ActiveRecord::Migration
  def change
    add_column :kols, :cal_time, :datetime
  end
end
