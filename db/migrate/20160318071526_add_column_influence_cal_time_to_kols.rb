class AddColumnInfluenceCalTimeToKols < ActiveRecord::Migration
  def change
    add_column :kols, :influence_cal_time, :datetime
  end
end
