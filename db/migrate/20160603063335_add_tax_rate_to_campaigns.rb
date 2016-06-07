class AddTaxRateToCampaigns < ActiveRecord::Migration
  def change
    # add_column :campaigns, :tax_rate, :float
    add_column :campaigns, :actual_per_action_budget, :float

    # Campaign.update_all(:tax_rate => 1)
    Campaign.all.each do  |campaign|
      campaign.actual_per_action_budget =  campaign.per_action_budget
    end
    User.create(:mobile_number => User::PlatformMobile, :name => 'plattform')
  end

end
