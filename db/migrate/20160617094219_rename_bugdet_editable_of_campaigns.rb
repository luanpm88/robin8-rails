class RenameBugdetEditableOfCampaigns < ActiveRecord::Migration
  def change
    rename_column :campaigns, :bugdet_editable, :budget_editable
  end
end
