class AddColumnActualDeadlineTimeToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :actual_deadline_time, :datetime
  end
end
