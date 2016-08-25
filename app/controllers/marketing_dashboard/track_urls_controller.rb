class MarketingDashboard::TrackUrlsController < MarketingDashboard::BaseController
  def index
    authorize! :read, TrackUrl
    @q = TrackUrl.enabled.ransack(params[:q])
    @track_urls = @q.result.order("created_at desc").paginate(paginate_params)
  end

  def new
    authorize! :read, TrackUrl

    @track_url = TrackUrl.new
  end

  def create
    authorize! :update, TrackUrl

    @track_url = TrackUrl.new(params.require(:track_url).permit(:origin_url, :desc))
    if @track_url.save
      redirect_to marketing_dashboard_track_urls_url
    else
      flash[:alert] = @track_url.errors.messages.values.flatten.join("\n")
      render :new
    end
  end

  def edit
    authorize! :read, TrackUrl

    @track_url = TrackUrl.enabled.find(params[:id])
  end

  def update
    authorize! :update, TrackUrl

    @track_url = TrackUrl.enabled.find(params[:id])
    if @track_url.update(params.require(:track_url).permit(:origin_url, :desc))
      redirect_to marketing_dashboard_track_urls_url
    else
      flash[:alert] = @track_url.errors.messages.values.flatten.join("\n")
      render :edit
    end
  end

  def destroy
    authorize! :update, TrackUrl

    @track_url = TrackUrl.enabled.find(params[:id])
    if @track_url.update(enabled: false)
      flash[:notice] = "移除追踪链接完成"
    else
      flash[:alert] = @track_url.errors.messages.values.flatten.join("\n")
    end
    redirect_to marketing_dashboard_track_urls_url
  end
end
