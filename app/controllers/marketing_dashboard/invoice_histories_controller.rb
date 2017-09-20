class MarketingDashboard::InvoiceHistoriesController < MarketingDashboard::BaseController
  def index
    authorize! :read, Invoice
    @invoice_histories = InvoiceHistory.all

    if params[:pending]
      @invoice_histories = @invoice_histories.where(status: 'pending')
    elsif params[:sent]
      @invoice_histories = @invoice_histories.where(status: 'sent')
    end

    @q = @invoice_histories.ransack(params[:q])
    @invoice_histories = @q.result.order('created_at DESC')
    respond_to do |format|
      format.html do
        @invoice_histories = @invoice_histories.paginate(paginate_params)
        render 'index'
      end

      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"发票记录#{Time.now.strftime("%Y%m%d%H%M%S")}.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
        render 'index'
      end
    end
  end

  def send_express
    authorize! :update, Invoice
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
