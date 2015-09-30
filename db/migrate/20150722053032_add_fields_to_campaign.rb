class AddFieldsToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :concepts, :text
    add_column :campaigns, :summaries, :text
    add_column :campaigns, :hashtags, :text
  end
end
