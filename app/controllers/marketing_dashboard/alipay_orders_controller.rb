class MarketingDashboard::AlipayOrdersController < MarketingDashboard::BaseController
  def index
    if params[:pending]
      @alipay_orders = AlipayOrder.where(status: 'pending').order('created_at DESC').paginate(paginate_params)
    elsif params[:paid]
      @alipay_orders = AlipayOrder.where(status: 'paid').order('created_at DESC').paginate(paginate_params)
    else
      @alipay_orders = AlipayOrder.all.order('created_at DESC').paginate(paginate_params)
    end
  end

  def search
    if params[:trade_no]
      search_by = params[:search_key]
      @alipay_orders = AlipayOrder.where("trade_no = ? OR alipay_trade_no = ?", search_by, search_by).paginate(paginate_params)

      render 'index' and return
    else
      search_by = params[:search_key]

      if @user = User.where("id LIKE ? OR name LIKE ? OR mobile_number LIKE ? OR email LIKE ?", search_by, search_by, search_by, search_by).paginate(paginate_params).first
        @alipay_orders = @user.alipay_orders.order('created_at DESC').paginate(paginate_params)

        render 'index' and return
      else
        render json: {error: "没有这个用户"} and return
      end
    end
  end

  def campaigns
    @campaigns = Campaign.where(:pay_way => "alipay").order('created_at DESC').paginate(paginate_params)
  end

  def search_campaigns
    if params[:trade_no]
      search_by = params[:search_key]
      @campaigns = Campaign.where(:pay_way => "alipay").where("trade_no = ? OR alipay_trade_no = ?", search_by, search_by).order('created_at DESC').paginate(paginate_params)
      render 'campaigns' and return
    else
      search_by = params[:search_key]
      if @user = User.where("id LIKE ? OR name LIKE ? OR mobile_number LIKE ? OR email LIKE ?", search_by, search_by, search_by, search_by).paginate(paginate_params).first
        @campaigns = Campaign.where(:pay_way => "alipay").where(:user_id => @user.id).order('created_at DESC').paginate(paginate_params)

        render 'campaigns' and return
      else
        render json: {error: "没有这个用户"} and return
      end
    end
  end
end
