class MarketingDashboard::CpsPromotionOrdersController < MarketingDashboard::BaseController
  def index
    authorize! :read, CpsArticle
    @q = CpsPromotionOrder.ransack(params[:q])
    @cps_promotion_orders = @q.result.includes(:kol, :cps_article).order('created_at desc').paginate(paginate_params)
  end

  def items
    authorize! :read, CpsArticle
    @q = CpsPromotionOrderItem.ransack(params[:q])
    @cps_promotion_order_items = @q.result.includes(:cps_promotion_order, :cps_material).order('created_at desc').paginate(paginate_params)
    # @order = CpsPromotionOrder.find params[:id]
    # @items =  @order.cps_promotion_order_items
  end

end
