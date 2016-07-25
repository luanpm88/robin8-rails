class AddMaterialFieldToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :materials, :string
  end
end
