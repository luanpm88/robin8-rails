class AddIsLimitClickCountToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :is_limit_click_count, :boolean, default: true
  end
end
