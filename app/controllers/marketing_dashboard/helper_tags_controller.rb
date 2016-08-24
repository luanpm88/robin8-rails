class MarketingDashboard::HelperTagsController < MarketingDashboard::BaseController
  def index
    authorize! :read, HelperTag
    @helper_tags = HelperTag.all.order('created_at DESC').paginate(paginate_params)
  end

  def new
    authorize! :read, HelperTag
    @title = "新建分类"
    @helper_tag = HelperTag.new
  end

  def create
    authorize! :update, HelperTag
    @helper_tag = HelperTag.new(params.require(:helper_tag).permit(:title))
    if @helper_tag.save
      redirect_to marketing_dashboard_helper_tags_url
    else
      flash[:alert] = @helper_tag.errors.messages.values.flatten.join("\n")
      render :new
    end
  end

  def show
    authorize! :read, HelperTag
  end

  def edit
    authorize! :read, HelperTag
    @title = "编辑分类"
    @helper_tag = HelperTag.find(params[:id])
  end

  def update
    authorize! :update, HelperTag
    @helper_tag = HelperTag.find(params[:id])
    if @helper_tag.update_attributes(params.require(:helper_tag).permit(:title))
      redirect_to marketing_dashboard_helper_tags_url
    else
      flash[:alert] = @helper_tag.errors.messages.values.flatten.join("\n")
      render :edit
    end
  end
end
