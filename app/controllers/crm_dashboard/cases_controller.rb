class CrmDashboard::CasesController < CrmDashboard::BaseController

  def index
    @cases = Crm::Case.all.order('created_at DESC').paginate(paginate_params)
  end

  def new
    @case = Crm::Case.new
  end

  def create
    @case = Crm::Case.new(case_params)
    if @case.save
      flash[:notice] = "创建成功"
      redirect_to action: :index
    else
      flash[:alert] = "创建失败"
      render :new
    end
  end

  def edit
    @case = Crm::Case.find(params[:id])
  end

  def update
    @case = Crm::Case.find(params[:id])
    @case.update_attributes
    if @case.errors.empty?
      flash[:notice] = "修改成功"
      redirect_to action: :index
    else
      flash[:alert] = "修改失败"
      render :edit
    end
  end

  def show
    @case = Crm::Case.find(params[:id])
  end

  def destroy
    @case = Crm::Case.find(params[:id])
    @case.destroy
    if @case.destroyed?
      flash[:notice] = "删除成功"
      redirect_to action: :index
    else
      flash[:alert] = "删除失败，请重试"
    end
  end

  private

  def case_params
    params.require(:case).permit(:name)
  end
end
