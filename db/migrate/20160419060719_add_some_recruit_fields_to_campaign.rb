class AddSomeRecruitFieldsToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :task_description, :text
    add_column :campaigns, :recruit_start_time, :datetime
    add_column :campaigns, :recruit_end_time, :datetime

    add_column :campaigns, :address, :string
    add_column :campaigns, :hide_brand_name, :boolean, default: false
    add_column :campaigns, :end_apply_check, :boolean, :default => false
  end
end
