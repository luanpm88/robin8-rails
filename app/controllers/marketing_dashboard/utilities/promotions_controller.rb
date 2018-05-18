class MarketingDashboard::Utilities::PromotionsController < MarketingDashboard::BaseController

  def index
    @promotions = Promotion.order(state: :desc, updated_at: :desc).paginate(paginate_params)
  end

  def new
    @promotion = Promotion.new
  end

  def create
    promotion = Promotion.new(params[:promotion].permit!)


    promotion.rate      = promotion.rate.to_f/100
    promotion.start_at  = promotion.start_at.beginning_of_day
    promotion.end_at    = promotion.end_at.end_of_day

    if promotion.save!
      flash[:notice] = '创建成功'
      redirect_to marketing_dashboard_utilities_promotions_path
    else
      flash[:alert] = '创建成功'
      render :new
    end
  end

  def invalid
    promotion = Promotion.find(params[:id])

    if promotion.update_attributes!(state: false)
      flash[:notice] = '修改成功'
    else
      flash[:alert] = '修改失败'
    end
    redirect_to marketing_dashboard_utilities_promotions_path
  end

end
