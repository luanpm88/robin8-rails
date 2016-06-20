class AddInvalidReasonToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :invalid_reasons, :string
  end
end
