class MarketingDashboard::TrackUrlsController < ApplicationController
  def index
    @track_urls = TrackUrl.paginate(paginate_params)
  end
end
