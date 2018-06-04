class AddAttrsToCampaign < ActiveRecord::Migration
  def change
  	add_column :campaigns, :used_credit, :boolean
  	add_column :campaigns, :credit_amount, :integer
  end
end
