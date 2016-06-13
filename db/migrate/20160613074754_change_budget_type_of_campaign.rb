class ChangeBudgetTypeOfCampaign < ActiveRecord::Migration
  def change
    change_column :campaigns, :budget, :decimal, precision: 13, scale: 3
    change_column :campaigns, :need_pay_amount, :decimal, precision: 13, scale: 3
  end
end
