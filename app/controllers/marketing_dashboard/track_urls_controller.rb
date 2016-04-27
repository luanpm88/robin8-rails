class MarketingDashboard::TrackUrlsController < MarketingDashboard::BaseController
  def index
    @track_urls = TrackUrl.paginate(paginate_params)
  end

  def new
    @track_url = TrackUrl.new
  end

  def create
    @track_url = TrackUrl.new(params.require(:track_url).permit(:origin_url, :desc))
    if @track_url.save
      redirect_to marketing_dashboard_track_urls_url
    else
      flash[:alert] = @track_url.errors.messages.values.flatten.join("\n")
      render :new
    end
  end

  def edit
    @track_url = TrackUrl.find(params[:id])
  end

  def update
    @track_url = TrackUrl.find(params[:id])
    if @track_url.update(params.require(:track_url).permit(:origin_url, :desc))
      redirect_to marketing_dashboard_track_urls_url
    else
      flash[:alert] = @track_url.errors.messages.values.flatten.join("\n")
      render :edit
    end
  end
end
