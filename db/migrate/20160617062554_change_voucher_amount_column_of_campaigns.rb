class ChangeVoucherAmountColumnOfCampaigns < ActiveRecord::Migration
  def change
    change_column :campaigns, :voucher_amount, :decimal, precision: 12, scale: 2
  end
end
