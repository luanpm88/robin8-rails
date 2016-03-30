class MarketingDashboard::StasticDatasController < MarketingDashboard::BaseController
  def index
    @stastic_datas = StasticData.all.order('id DESC').paginate(paginate_params)
  end
end
