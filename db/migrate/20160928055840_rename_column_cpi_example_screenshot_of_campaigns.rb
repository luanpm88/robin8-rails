class RenameColumnCpiExampleScreenshotOfCampaigns < ActiveRecord::Migration
  def change
    rename_column :campaigns, :cpi_example_screenshot, :example_screenshot
  end
end
