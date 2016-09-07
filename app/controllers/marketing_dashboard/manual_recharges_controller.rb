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

  def add_seller
    @transaction = Transaction.find(params[:id])
    if request.get?
      render :add_seller
    else
      @transaction.account.update(seller_id: params[:seller_id])
      redirect_to :back, notice: '添加成功'
    end
  end
end
