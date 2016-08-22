class MarketingDashboard::AlipayOrdersController < MarketingDashboard::BaseController
  def index
    @alipay_orders = AlipayOrder.all

    if params[:pending]
      @alipay_orders = @alipay_orders.where(status: 'pending')
    elsif params[:paid]
      @alipay_orders = @alipay_orders.where(status: 'paid')
    end

    @q = @alipay_orders.ransack(params[:q])
    @alipay_orders = @q.result.order('created_at DESC').paginate(paginate_params)
  end

  def campaigns
    @campaigns = Campaign.where(:pay_way => "alipay")

    @q = @campaigns.ransack(params[:q])
    @campaigns = @q.result.order('created_at DESC').paginate(paginate_params)
  end

  def change_campaign_desc
    @campaign = Campaign.find params[:campaign_id]
    @campaign.update(:admin_desc => params[:admin_desc])
    render :json => {:status => "ok"}
  end
end
