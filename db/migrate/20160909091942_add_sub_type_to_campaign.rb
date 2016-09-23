class AddSubTypeToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :sub_type, :string
  end
end
