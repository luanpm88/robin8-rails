class MarketingDashboard::InvoiceHistoriesController < MarketingDashboard::BaseController
  def index
    if params[:pending]
      @invoice_histories = InvoiceHistory.where(status: 'pending').order('created_at DESC').paginate(paginate_params)
    elsif params[:sent]
      @invoice_histories = InvoiceHistory.where(status: 'sent').order('created_at DESC').paginate(paginate_params)
    else
      @invoice_histories = InvoiceHistory.all.order('created_at DESC').paginate(paginate_params)
    end
  end

  def search
    search_by = params[:search_key]
    @user = User.where("id LIKE ? OR name LIKE ? OR mobile_number LIKE ? OR email LIKE ?", search_by, search_by, search_by, search_by).paginate(paginate_params).first
    @invoice_histories = @user.invoice_histories.order('created_at DESC').paginate(paginate_params)

    render 'index' and return
  end

  def send_express
    tracking_no = params[:tracking_no]
    @invoice_history = InvoiceHistory.find(params[:id])
    @invoice_history.update_attributes(tracking_number: tracking_no, status: 'sent')
    redirect_to marketing_dashboard_invoice_histories_path
  end
end
