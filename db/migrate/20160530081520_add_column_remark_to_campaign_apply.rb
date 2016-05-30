class AddColumnRemarkToCampaignApply < ActiveRecord::Migration
  def change
    add_column :campaign_applies, :remark, :string
  end
end
