class MarketingDashboard::ManualRechargesController < MarketingDashboard::BaseController
  def index
    @transactions = Transaction.where(account_type: 'User').where(direct: "income").where(subject: ["manual_recharge", "manaual_recharge"]).order('created_at DESC').paginate(paginate_params)
  end

  def search
    search_by = params[:search_key]

    if @user = User.where("id LIKE ? OR name LIKE ? OR mobile_number LIKE ? OR email LIKE ?", search_by, search_by, search_by, search_by).paginate(paginate_params).first
      @transactions = @user.transactions.where(account_type: 'User').where(direct: "income").where(subject: ["manual_recharge", "manaual_recharge"]).order('created_at DESC').paginate(paginate_params)
      render 'index' and return
    else
      render json: {error: "没有这个用户"} and return 
    end
  end
end
