class AddColumnExpectEffectToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :expect_effect, :string
  end
end
