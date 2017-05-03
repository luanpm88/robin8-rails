class AddActivityIdToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :activity_id, :string
  end
end
