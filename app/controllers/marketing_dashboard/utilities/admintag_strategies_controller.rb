class MarketingDashboard::Utilities::AdmintagStrategiesController < MarketingDashboard::BaseController
  def index
  	@admintag_strategies = AdmintagStrategy.includes(:admintag).all.paginate(paginate_params)
  end

  def new
  end
end
