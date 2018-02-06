class AddCountDownToCampaign < ActiveRecord::Migration
  def change
  	add_column :campaigns, :countdown, :datetime
  end
end
