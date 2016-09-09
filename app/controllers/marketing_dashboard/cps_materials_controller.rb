class MarketingDashboard::CpsMaterialsController < MarketingDashboard::BaseController
  def index
    authorize! :read, CpsArticle
    @q = CpsMaterial.ransack(params[:q])
    @cps_materials = @q.result.order('position DESC, created_at desc').paginate(paginate_params)
  end

  def create
    authorize! :update, CpsArticle
    material_url_arr = params[:material_urls].split(",")
    if material_url_arr.size == 0
      flash[:error] = "请输入网址"
    elsif material_url_arr.size > 100
      flash[:error] = "商品数量一次不能超过100个"
    else
      CpsMaterial.sync_info_from_api(material_url_arr)
    end
    redirect_to :action => :index
  end

  def edit
    authorize! :read, CpsArticle
    @cps_material = CpsMaterial.find params[:id]
  end

  def update
    authorize! :read, CpsArticle
    params.permit!
    @cps_material = CpsMaterial.find params[:id]
    if @cps_material.update_attributes(params[:cps_material])
      redirect_to :action => :index
    else
      flash[:error] = "保存失败"
      render :action => :edit
    end
  end

end
