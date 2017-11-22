class MarketingDashboard::TalkingDataController < MarketingDashboard::BaseController
  def index
  	@talkingdata = Kol.where("talkingdata_promotion_name is not NULL").pluck(:talkingdata_promotion_name).uniq.paginate(paginate_params)
  end
end
