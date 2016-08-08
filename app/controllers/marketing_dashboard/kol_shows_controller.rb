class MarketingDashboard::KolShowsController < MarketingDashboard::BaseController
  def index
    @kol_shows = KolShow.where(:kol_id => params[:kol_id])
  end

  def new
    @kol_show = KolShow.new
    @kol_show.kol_id = params[:kol_id]
  end

  def create
    @kol_show = KolShow.new(permit_params)
    @kol_show.kol_id = params[:kol_id]
    if @kol_show.save
      flash[:notice] = "创建成功"
      redirect_to marketing_dashboard_kol_shows_path(:kol_id => params[:kol_id])
    else
      flash[:notice] = @kol_show.errors.messages.values.flatten.join("\n")
      render :new
    end
  end

  def edit
    @kol_show = KolShow.find(params[:id])
    params[:kol_id] = @kol_show.kol_id
  end

  def update
    @kol_show = KolShow.find(params[:id])
    params[:kol_id] = @kol_show.kol_id
    if @kol_show.update_attributes(permit_params)
      flash[:notice] = "编辑成功"
      redirect_to marketing_dashboard_kol_shows_path(:kol_id => params[:kol_id])
    else
      flash[:notice] = @kol_show.errors.messages.values.flatten.join("\n")
      render :new
    end
  end

  def destroy
    @kol_show = KolShow.find(params[:id])
    params[:kol_id] = @kol_show.kol_id
    @kol_show.delete
    flash[:notice] = "删除成功"
    redirect_to marketing_dashboard_kol_shows_path(:kol_id => params[:kol_id])
  end

  def permit_params
    params.require(:kol_show).permit(:kol_id, :title, :cover_url,
         :desc, :link, :provider, :like_count, :read_count, :repost_count,
          :comment_count)
  end
end
