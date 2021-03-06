ActiveAdmin.register Withdraw do

  member_action :unagree, :method => :put
  member_action :agree, :method => :put
  member_action :withdraw_history, :method => :get
  remove_filter :kol

  controller do
    def scoped_collection
      Withdraw.includes(:kol)   # includes User / Brand models in listing products
    end

    def unagree
      withdraw = Withdraw.find params[:id]
      if withdraw.kol.frozen_amount >= withdraw.credits
        withdraw.update_attributes(:status => 'rejected')
        redirect_to admin_withdraws_path
      else
        flash[:error] = "提现金额超出冻结金额"
        redirect_to admin_withdraws_path#, :notice => "提现金额超过可用余额"
      end
    end

    def agree
      withdraw = Withdraw.find params[:id]
      if withdraw.kol.frozen_amount >= withdraw.credits
        withdraw.update_attributes(:status => 'paid')
        redirect_to admin_withdraws_path
      else
        flash[:error] = "提现金额超出冻结金额"
        redirect_to admin_withdraws_path#, :notice => "提现金额超过可用余额"
      end
    end

    def withdraw_history
      @withdraw = Withdraw.find params[:id]
      @kol = Kol.find @withdraw.kol_id
      @transactions = Transaction.where("account_id = ? and account_type = ? and (subject = ? or subject = ?)", @kol.id, 'Kol', "withdraw", "campaign").uniq.order("created_at desc")
      @user_names = []
      @campaigns = []
      @campaign_invites = []
      @transactions.each do |t|
        if (t.direct == "income")
          @user_names << t.item.user.name
          @campaigns << t.item
          @campaign_invites << CampaignInvite.joins(:campaign, :kol).where("kols.id = ? AND campaigns.id = ?", @kol.id, t.item_id).first
        else
          @campaigns << ""
          @user_names << ""
          @campaign_invites << ""
        end

      end

    end
  end

  permit_params :status

  index do
    id_column
    # column :kol_id
    column "Kol" do |resource|
      (link_to resource.kol.id, "/admin/kols/#{resource.kol.id}", :target => "_blank")
    end

    column "total amount" do |resource|
      resource.kol.amount
    end

    column "frozen amount" do |resource|
      resource.kol.frozen_amount
    end
    column "avail amount" do |resource|
      resource.kol.avail_amount
    end
    column "mobile_number" do |resource|
      resource.kol.mobile_number
    end

    # column :withdraw_type
    column :real_name
    column :credits
    column :alipay_no
    # column :bank_name
    # column :bank_no

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
