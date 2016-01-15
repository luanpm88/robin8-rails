ActiveAdmin.register Withdraw do

  member_action :unagree, :method => :put
  member_action :agree, :method => :put
  member_action :withdraw_history, :method => :get

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

    def withdraw_history
      @withdraw = Withdraw.find params[:id]
      @kol = Kol.find @withdraw.kol_id
      @transactions = Transaction.where("account_id = ? and account_type = ? and (subject = ? or subject = ?)", 179, 'Kol', "withdraw", "campaign").order("created_at desc")
      @user_names = []
      @campaigns = []
      @campaign_invites = []
      @transactions.each do |t|
        if t.item
          @user_names << t.item.user.name
          @campaigns << t.item
          @campaign_invites << CampaignInvite.joins(:campaign, :kol).where("kols.id = ? AND campaigns.id = ?", @kol.id, t.item.id).first
        else
          @campaigns << nil
        end

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
    column "明细" do |my_resource|
      link_to "流水明细", withdraw_history_admin_withdraw_path(my_resource.id), :method => :get, :target => "_blank"
    end
  end
end
