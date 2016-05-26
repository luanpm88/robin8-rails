class MarketingDashboard::TransactionsController < MarketingDashboard::BaseController
  def index

  end

  def search
    if params[:trade_no]
      @transactions = Transaction.where(trade_no: params[:trade_no]).paginate(paginate_params)
      render 'index' and return
    end
    render nothing: true
  end
end
