class AddBugdetEditableToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :bugdet_editable, :boolean, :default => true
  end
end
