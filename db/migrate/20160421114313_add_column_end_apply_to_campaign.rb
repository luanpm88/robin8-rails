class AddColumnEndApplyToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :end_apply_check, :boolean, :default => false
  end
end
