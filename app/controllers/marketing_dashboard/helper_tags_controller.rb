class MarketingDashboard::HelperTagsController < MarketingDashboard::BaseController
  def index
    @helper_tags = HelperTag.all.order('created_at DESC').paginate(paginate_params)
  end

  def new
    @title = "新建分类"
    @helper_tag = HelperTag.new
  end

  def create
    @helper_tag = HelperTag.new(params.require(:helper_tag).permit(:title))
    if @helper_tag.save
      redirect_to marketing_dashboard_helper_tags_url
    else
      flash[:alert] = @helper_tag.errors.messages.values.flatten.join("\n")
      render :new
    end
  end

  def show
  end

  def edit
    @title = "编辑分类"
  end

  def update
  end
end