class MarketingDashboard::ManualRechargesController < MarketingDashboard::BaseController
  def index
    @transactions = Transaction.where({
      account_type: 'User',
      direct: "income",
      subject: ["manual_recharge", "manaual_recharge"]
    })

    @q = @transactions.ransack(params[:q])
    @transactions = @q.result.order('created_at DESC').paginate(paginate_params)
  end
end
