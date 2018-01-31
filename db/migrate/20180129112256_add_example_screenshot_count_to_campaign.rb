class AddExampleScreenshotCountToCampaign < ActiveRecord::Migration
  def change
  	add_column :campaigns, :example_screenshot_count, :integer, default: 1
  end
end
