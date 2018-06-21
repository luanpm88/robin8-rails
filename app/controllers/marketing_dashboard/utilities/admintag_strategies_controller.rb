class MarketingDashboard::Utilities::AdmintagStrategiesController < MarketingDashboard::BaseController
	before_filter :get_admintag_strategy, only: [:edit, :update]
  
  def index
  	@admintag_strategies = AdmintagStrategy.includes(:admintag).all.paginate(paginate_params)
  end

  def new
  	@admintag_strategy = AdmintagStrategy.new
  end

  def edit
  end

  def create
  	@admintag_strategy = AdmintagStrategy.new(admintag_strategy_params)

  	if @admintag_strategy.save!
      flash[:notice] = '创建成功'
      redirect_to marketing_dashboard_utilities_admintag_strategies_path
    else
      flash[:alert] = '创建失败'
      render :new
    end
  end

  def update
  	if @admintag_strategy.update_attributes!(admintag_strategy_params)
  		flash[:notice] = '更新成功'
      redirect_to marketing_dashboard_utilities_admintag_strategies_path
    else
      flash[:alert] = '更新失败'
      render :edit
    end
  end

  private

  def get_admintag_strategy
  	@admintag_strategy = AdmintagStrategy.find params[:id]
  end

  def admintag_strategy_params
  	_hash = params[:admintag_strategy].permit!

  	_hash[:unit_price_rate_for_kol] = _hash[:unit_price_rate_for_kol].to_f/100
  	_hash[:unit_price_rate_for_admin] = _hash[:unit_price_rate_for_admin].to_f/100
  	_hash[:master_income_rate] = _hash[:master_income_rate].to_f/100

  	_hash
  end

end
