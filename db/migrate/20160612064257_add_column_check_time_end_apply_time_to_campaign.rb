class AddColumnCheckTimeEndApplyTimeToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :check_time, :datetime
    add_column :campaigns, :end_apply_time, :datetime
  end
end
