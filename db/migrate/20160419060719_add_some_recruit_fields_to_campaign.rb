class AddSomeRecruitFieldsToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :task_description, :text
    add_column :campaigns, :recruit_start_time, :datetime
    add_column :campaigns, :recruit_end_time, :datetime
  end
end
