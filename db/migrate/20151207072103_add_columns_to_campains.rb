class AddColumnsToCampains < ActiveRecord::Migration
  def change
    add_column :campaigns, :url, :string
    add_column :campaigns, :per_click_budget, :double
    add_column :campaigns, :start_time, :datetime
    add_column :campaigns, :message, :text
  end
end
