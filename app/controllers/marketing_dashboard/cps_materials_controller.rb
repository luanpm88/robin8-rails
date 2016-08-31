class MarketingDashboard::CpsMaterialsController < MarketingDashboard::BaseController
  def index
    @q = CpsMaterial.ransack(params[:q])
    @cps_materials = @q.result.order('created_at DESC').paginate(paginate_params)
  end

  def create
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

end
