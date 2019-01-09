class MarketingDashboard::CreationsController < MarketingDashboard::BaseController
  def index
    @q    = Creation.ransack(params[:q])
    @creations = @q.result.order(created_at: :desc).paginate(paginate_params)
  end

  def show 
    @creation = Creation.find params[:id]
  end

  def agree
    @creation = Creation.find params[:id]
    if @creation.is_pending_status? 
      @creation.update(status: 'passed')
      flash[:alert] = "审核通过"
    else
      flash[:alert] = "该活动不是待审核状态，不能审核通过"
    end
    redirect_to  marketing_dashboard_creations_path
  end
end
