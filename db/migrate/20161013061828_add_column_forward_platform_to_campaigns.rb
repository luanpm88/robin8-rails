class AddColumnForwardPlatformToCampaigns < ActiveRecord::Migration
  def change
    Campaign.where("per_budget_type != 'recruit'").update_all(:sub_type => 'wechat')
  end
end
