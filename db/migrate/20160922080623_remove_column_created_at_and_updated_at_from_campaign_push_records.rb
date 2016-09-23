class RemoveColumnCreatedAtAndUpdatedAtFromCampaignPushRecords < ActiveRecord::Migration
  def change
    remove_column :campaign_push_records, :created_at
    remove_column :campaign_push_records, :updated_at
  end
end
