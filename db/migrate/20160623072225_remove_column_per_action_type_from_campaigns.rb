class RemoveColumnPerActionTypeFromCampaigns < ActiveRecord::Migration
  def change
    remove_column :campaigns, :per_action_type
  end
end
