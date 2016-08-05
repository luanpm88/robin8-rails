class AddBudgetToCampaginInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :social_account_id, :integer
    add_column :campaign_invites, :budget, :float
  end
end
