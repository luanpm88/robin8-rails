class ChangeBudgetTypeOfCampaign < ActiveRecord::Migration
  def change
    change_column :campaigns, :budget, :decimal, precision: 12, scale: 2
    change_column :campaigns, :need_pay_amount, :decimal, precision: 12, scale: 2
  end
end
