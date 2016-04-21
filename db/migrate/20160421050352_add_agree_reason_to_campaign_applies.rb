class AddAgreeReasonToCampaignApplies < ActiveRecord::Migration
  def change
    add_column :campaign_applies, :agree_reason, :string
  end
end
