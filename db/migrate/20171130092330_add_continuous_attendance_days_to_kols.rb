class AddContinuousAttendanceDaysToKols < ActiveRecord::Migration
  def change
    add_column :kols, :continuous_attendance_days, :integer, :default => 0
  end
end
