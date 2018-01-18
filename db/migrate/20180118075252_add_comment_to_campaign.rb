class AddCommentToCampaign < ActiveRecord::Migration
  def change
  	change_column :campaigns, :example_screenshot, :string, limit: 1024
  	add_column :campaigns, :comment, :string
  end
end
