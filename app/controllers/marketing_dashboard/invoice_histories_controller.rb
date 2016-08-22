class MarketingDashboard::InvoiceHistoriesController < MarketingDashboard::BaseController
  def index
    @invoice_histories = InvoiceHistory.all

    if params[:pending]
      @invoice_histories = @invoice_histories.where(status: 'pending')
    elsif params[:sent]
      @invoice_histories = @invoice_histories.where(status: 'sent')
    end

    @q = @invoice_histories.ransack(params[:q])
    @invoice_histories = @q.result.order('created_at DESC').paginate(paginate_params)
  end

  def send_express
    tracking_no = params[:tracking_no]
    unless tracking_no.present?
      flash.now[:alert] = "快递单号不能为空, 请重新输入"
      render 'send' and return
    end
    @invoice_history = InvoiceHistory.find(params[:id])
    @invoice_history.update_attributes(tracking_number: tracking_no, status: 'sent')
    if @invoice_history.errors.messages.present?
      flash.now[:alert] = "快递单号重复，请检查后重新输入"
      render 'send' and return
    else
      redirect_to marketing_dashboard_invoice_histories_path
    end
  end
end
