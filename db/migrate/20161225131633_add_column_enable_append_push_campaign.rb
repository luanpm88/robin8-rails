class AddColumnEnableAppendPushCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :enable_append_push, :boolean, :default => true
  end
end
