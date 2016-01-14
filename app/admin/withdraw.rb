ActiveAdmin.register Withdraw do

  member_action :unagree, :method => :put
  member_action :agree, :method => :put

  controller do
    def unagree
      withdraw = Withdraw.find params[:id]
      withdraw.update_column(:status , 'rejected')
      redirect_to admin_withdraws_path
    end

    def agree
      withdraw = Withdraw.find params[:id]
      if withdraw.kol.avail_amount > withdraw.credits
        ActiveRecord::Base.transaction do
          withdraw.update_column(:status , 'paid')
          withdraw.kol.payout(withdraw.credits, 'withdraw')
        end
        redirect_to admin_withdraws_path
      else
        flash[:error] = "提现金额超过可用余额"
        redirect_to admin_withdraws_path, :notice => "提现金额超过可用余额"
      end
    end
  end

  permit_params :status

  index do
    id_column
    column :kol_id
    column "avail amount" do |resource|
      resource.kol.avail_amount
    end
    column "mobile_number" do |resource|
      resource.kol.mobile_number
    end

    column :withdraw_type
    column :real_name
    column :credits
    column :alipay_no
    column :bank_name
    column :bank_no

    column "status"
    column "operate" do |my_resource|
      if my_resource.status == 'pending'
        (link_to 'agree ', agree_admin_withdraw_path(my_resource.id), :method => :put )   +
        (link_to 'unagree ', unagree_admin_withdraw_path(my_resource.id), :method => :put )
      else
        " "
      end
    end
  end
end
