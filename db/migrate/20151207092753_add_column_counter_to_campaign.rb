class AddColumnCounterToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :max_click, :integer
    add_column :campaigns, :avail_click, :integer, :default => 0
    add_column :campaigns, :total_click, :integer, :default => 0

    add_column :campaigns, :finish_remark, :string
  end
end
