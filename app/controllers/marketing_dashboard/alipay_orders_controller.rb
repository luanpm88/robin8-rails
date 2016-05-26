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

      @user = User.where("id LIKE ? OR name LIKE ? OR mobile_number LIKE ? OR email LIKE ?", search_by, search_by, search_by, search_by).paginate(paginate_params).first
      @alipay_orders = @user.alipay_orders.order('created_at DESC').paginate(paginate_params)

      render 'index' and return
    end
  end
end
