require 'csv'

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

    respond_to do |format|
      format.html
      format.csv {
        csv_string = CSV.generate do |csv|
          csv << ["活动ID", "活动名称", "品牌主ID", "品牌名称", "订单号", "支付宝订单号", "支付金额", "支付状态", "下单时间", "销售人员", "备注", "修改备注"]
          @campaigns.each do |c|
            csv << [c.id, c.name, c.user.id, c.user.name, c.trade_number, c.alipay_trade_no, c.alipay_amount, c.alipay_status.zero?, c.created_at.strftime("%Y-%m-%d %H:%M") ]
          end
        end
        send_data csv_string, :filename => "支付宝直接付款发起的活动 #{Time.current.strftime("%Y-%m-%d")}.csv"
    }
    end
  end

  def change_campaign_desc
    authorize! :update, AlipayOrder
    @campaign = Campaign.find params[:campaign_id]
    @campaign.update(:admin_desc => params[:admin_desc])
    render :json => {:status => "ok"}
  end

  def add_seller
    @alipay_order = AlipayOrder.find(params[:id])
    if request.get?
      render :add_seller
    else
      @alipay_order.user.update_attributes(seller_id: params[:seller_id])
      redirect_to :back, notice: '添加成功'
    end
  end

private
  def get_alipay_orders
    authorize! :read, AlipayOrder

    @q = @alipay_orders.ransack(params[:q])
    @alipay_orders = @q.result.order('created_at DESC').paginate(paginate_params)

    respond_to do |format|
      format.html {render :index}
      format.csv {
        csv_string = CSV.generate do |csv|
          csv << ["ID", "品牌主ID", "品牌昵称", "品牌主手机", "下单时间", "订单号", "支付宝订单号", "充值金额", "税费", "充值状态", "查看流水（若未付款则为空）"]
          @alipay_orders.each do |c|
            csv << [c.id, c.user_id, c.user.smart_name, c.user.mobile_number,  c.created_at.strftime("%Y-%m-%d %H:%M:%S"), c.trade_no, c.alipay_trade_no, c.credits, c.tax, c.status, "查看流水" ]
          end
        end
        send_data csv_string, :filename => "支付宝充值列表##{Time.current.strftime("%Y-%m-%d")}.csv"
      }
    end
  end
end
