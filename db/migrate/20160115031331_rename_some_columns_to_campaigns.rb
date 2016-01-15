class RenameSomeColumnsToCampaigns < ActiveRecord::Migration
  def change
    rename_column :campaigns, :per_click_budget, :per_action_budget
    rename_column :campaigns, :max_click, :max_action
  end
end
