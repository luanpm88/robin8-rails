class AddPerBudgetTypeColumnsToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :per_budget_type, :string
  end
end
