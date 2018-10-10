class MarketingDashboard::TagsController < MarketingDashboard::BaseController

  def index
    @tags = Tag.all
    load_tags
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(params.require(:tag).permit(:name, :label))
    if @tag.save
      flash[:notice] = "创建成功"
      redirect_to action: :index
    else
      flash[:alert] = "创建失败"
      render 'new'
    end
  end

  def add_circle
    @circles = Circle.all
    @tag = Tag.find params[:tag_id]
    render 'add_circle' and return if request.method.eql? 'GET'

    @select_circles = Circle.where(id: params[:circle_ids])

    @tag.circles.delete_all

    if @select_circles.present?
      @tag.circles << @select_circles
    end

    redirect_to marketing_dashboard_tags_path
  end

  def remove_circle
    @tag = Tag.find params[:tag_id]
    @circle = Circle.find params[:circle_id]
    @tag.circles.delete(@circle)

    redirect_to marketing_dashboard_tags_path
  end


  private
  def load_tags
    authorize! :read, Tag

    @q    = @tags.includes(:circles).ransack(params[:q])
    @tags = @q.result.order('id DESC')

    respond_to do |format|
      format.html do
        @tags = @tags.paginate(paginate_params)
        render 'index'
      end
    end
  end


end
