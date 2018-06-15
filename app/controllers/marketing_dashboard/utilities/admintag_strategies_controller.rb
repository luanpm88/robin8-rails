class MarketingDashboard::Utilities::AdmintagStrategiesController < MarketingDashboard::BaseController
  
  def index
  	@admintag_strategies = AdmintagStrategy.includes(:admintag).all.paginate(paginate_params)
  end

  def new
  	@admintag_strategy = AdmintagStrategy.new
  end

  def create
  	admintag_strategy = AdmintagStrategy.new(params[:admintag_strategy].permit!)

  	admintag_strategy.unit_price_rate_for_kol = admintag_strategy.unit_price_rate_for_kol.to_f/100
  	admintag_strategy.unit_price_rate_for_admin = admintag_strategy.unit_price_rate_for_admin.to_f/100
  	admintag_strategy.master_income_rate = admintag_strategy.master_income_rate.to_f/100

  	if admintag_strategy.save!
      flash[:notice] = '创建成功'
      redirect_to marketing_dashboard_utilities_admintag_strategies_path
    else
      flash[:alert] = '创建失败'
      render :new
    end
  end

end
