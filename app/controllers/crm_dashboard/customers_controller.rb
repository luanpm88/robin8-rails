class CrmDashboard::CustomersController < CrmDashboard::BaseController

  def index
    @customers = Crm::Customer.all.order('created_at DESC').paginate(paginate_params)
  end
end
