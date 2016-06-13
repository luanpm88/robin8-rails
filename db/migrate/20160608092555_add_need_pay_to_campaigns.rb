class AddNeedPayToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :need_pay_amount, :decimal, default: 0
    add_column :campaigns, :pay_way, :string
    add_column :campaigns, :used_voucher, :boolean, default: false
    add_column :campaigns, :voucher_amount, :decimal, default: 0
  end
end
