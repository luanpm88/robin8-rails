class MarketingDashboard::WithdrawsController < MarketingDashboard::BaseController
  def index
    @withdraws = Withdraw.all.paginate(paginate_params)
  end
end
