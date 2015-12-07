class AddColumnCounterToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :max_click, :integer
    add_column :campaigns, :valid_click, :integer, :default => 0
    add_column :campaigns, :total_click, :integer, :default => 0
  end
end
