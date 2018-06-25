class AddLogoToAdmintagStrategies < ActiveRecord::Migration
  def change
  	add_column :admintag_strategies, :logo, :string
  end
end
