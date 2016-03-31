class MarketingDashboard::StasticDatasController < MarketingDashboard::BaseController
  def index
    @stastic_datas = StasticData.all.order('id DESC').paginate(paginate_params)
  end

  def new
    @stastic_data = StasticData.new
  end

  def create
    @stastic_data = StasticData.new stastic_data_params

    respond_to do |format|
      if @stastic_data.save
        format.html { redirect_to marketing_dashboard_stastic_datas_path, notice: 'Create new stastic data successfully!' }
      else
        format.html { }
      end
    end
  end

  private
  def stastic_data_params
    params.require(:stastic_data).permit(:start_time, :end_time)
  end
end
