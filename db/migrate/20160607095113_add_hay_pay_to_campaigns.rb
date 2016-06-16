class AddHayPayToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :has_pay, :boolean, :default => false
  end
end
