class MarketingDashboard::CreationsController < MarketingDashboard::BaseController
  before_filter :get_creation, except: [:index]

  def index
    @q    = Creation.ransack(params[:q])
    @creations = @q.result.order(created_at: :desc).paginate(paginate_params)
  end

  def show
  end

  def auditing
  end

  def pass
    if @creation.is_pending? 
      @creation.update(status: 'passed')
      flash[:alert] = "审核通过"
    else
      flash[:alert] = "该活动不是待审核状态，不能审核通过"
    end
    redirect_to  marketing_dashboard_creations_path
  end

  private

  def get_creation
    @creation = Creation.find params[:id]
  end
end
