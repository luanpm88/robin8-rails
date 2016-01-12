class AddPerPostBudgetColumnToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :per_post_budget, :double
  end
end
