class MarketingDashboard::CreatorsController < MarketingDashboard::BaseController
  def index
    @q    = Creator.includes(:kol, :circles, :terraces).ransack(params[:q])
    @creators = @q.result.order(created_at: :desc).paginate(paginate_params)
  end

  def update
    @creator = Creator.find params[:id]
    status = params['status']
    if params['status'] == "passed"
      @creator.update_column(:status, 1)
      @creator.is_read.set 1
      @creator.kol.update_column(:role_apply_status, 'passed')
    elsif params['status'] == "rejected"
      @creator.update_column(:status, -1)
      @creator.is_read.set -1
      @creator.kol.update_column(:role_apply_status, 'rejected')
    end

    flash[:notice] = "修改成功"
    redirect_to :action => :index
  end

  def show 
    @creator = Creator.find params[:id]
  end
end
