class AddColumnEvaluationStatusToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :evaluation_status, :string, :default => 'pending'    # pending, evaluating, evaluated

    Campaign.where(status: 'settled').update_all(evaluation_status: 'evaluating')
  end
end
