class AddColumnPerSubActionTypeToCampaigns < ActiveRecord::Migration
  def change
    add_column :users, :appid, :string

    add_column :campaigns, :per_action_type, :string
    add_column :campaigns, :action_desc, :string
    add_column :campaigns, :appid, :string
  end
end
