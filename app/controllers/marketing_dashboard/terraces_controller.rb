class MarketingDashboard::TerracesController < MarketingDashboard::BaseController

  before_filter :get_terrace, only: [:edit, :update, :destroy]

  def index
    @terraces = Terrace.all
  end

  def new
    @terrace = Terrace.new
  end

  def create
    @terrace = Terrace.new(terrace_params)
    if @terrace.save
      flash[:notice] = "创建成功"
      redirect_to action: :index
    else
      flash[:alert] = "创建失败#{@terrace.errors.messages}"
      render 'new'
    end
  end

  def edit
  end

  def update
    if @terrace.update_attributes(terrace_params)
      flash[:notice] = "修改成功"
      redirect_to :action => :index
    else
      flash[:alert] = "修改失败#{@terrace.errors.messages}"
      render 'edit'
    end
  end

  def destroy
    @terrace.destroy
    flash[:notice] = "删除成功"
    redirect_to action: :index
  end

  private 

  def get_terrace
    @terrace = Terrace.find params[:id]
  end

  def terrace_params
    params.require(:terrace).permit(:name, :short_name, :avatar, :address)
  end
end
