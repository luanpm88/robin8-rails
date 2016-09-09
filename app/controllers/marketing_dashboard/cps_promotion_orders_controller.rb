class MarketingDashboard::CpsPromotionOrdersController < MarketingDashboard::BaseController
  def index
    authorize! :read, CpsArticle
    @q = CpsPromotionOrder.ransack(params[:q])
    @cps_promotion_orders = @q.result.order('position DESC, created_at desc').paginate(paginate_params)
  end

end
