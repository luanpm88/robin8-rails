class AddAlizhongbaoStuffToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :ali_task_id, :integer
    add_column :campaigns, :ali_task_type_id, :integer
    change_column :kols, :cid, :string
  end
end
