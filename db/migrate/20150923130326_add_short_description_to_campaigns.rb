class AddShortDescriptionToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :short_description, :string
  end
end
