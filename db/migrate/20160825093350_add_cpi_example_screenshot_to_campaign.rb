class AddCpiExampleScreenshotToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :cpi_example_screenshot, :string
    add_column :campaigns, :remark, :string
  end
end
