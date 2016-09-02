class CrmDashboard::CustomersController < CrmDashboard::BaseController

  def index
    @customers = Crm::Customer.all.order('created_at DESC').paginate(paginate_params)
    @q = @customers.ransack(params[:q])
    @customers = @q.result.order('created_at DESC').paginate(paginate_params)
  end
end
