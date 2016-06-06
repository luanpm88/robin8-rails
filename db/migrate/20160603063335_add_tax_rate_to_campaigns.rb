class AddTaxRateToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :tax_rate, :float

    Campaign.update_all(:tax_rate => 1)
    User.create(:mobile_number => User::PlatformMobile, :name => 'plattform')
  end

end
