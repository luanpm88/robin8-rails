class MarketingDashboard::AlipayOrdersController < MarketingDashboard::BaseController
  def index
    @alipay_orders = AlipayOrder.all
    get_alipay_orders
  end

  def from_pc
    @alipay_orders = AlipayOrder.where(recharge_from: ["pc", nil])
    get_alipay_orders
  end

  def from_app
    @alipay_orders = AlipayOrder.where(recharge_from: "app")
    get_alipay_orders
  end

  def campaigns
    authorize! :read, AlipayOrder
    @campaigns = Campaign.where(:pay_way => "alipay")

    @q = @campaigns.ransack(params[:q])
    @campaigns = @q.result.order('created_at DESC').paginate(paginate_params)
  end

  def change_campaign_desc
    authorize! :update, AlipayOrder
    @campaign = Campaign.find params[:campaign_id]
    @campaign.update(:admin_desc => params[:admin_desc])
    render :json => {:status => "ok"}
  end

private
  def get_alipay_orders
    authorize! :read, AlipayOrder

    @q = @alipay_orders.ransack(params[:q])
    @alipay_orders = @q.result.order('created_at DESC').paginate(paginate_params)
    render :index
  end
end
