class MarketingDashboard::CirclesController < MarketingDashboard::BaseController

  def index
    @circles = Circle.all
    load_circle
  end

  def new 
    @circle = Circle.new
  end

  def create 
    @circle = Circle.new(params.require(:circle).permit(:name, :label))
    if @circle.save
      flash[:notice] = "创建成功"
      redirect_to action: :index
    else
      flash[:alert] = "创建失败"
      render 'new'
    end
  end

  def add_tag
    @tags = Tag.all 
    @circle = Circle.find params[:circle_id]
    render 'add_tag' and return if request.method.eql? 'GET'


    @select_tags = Tag.where(id: params[:tag_ids])

    @circle.tags.delete_all

    if @select_tags.present?
      @circle.tags << @select_tags
    end

    redirect_to marketing_dashboard_circles_path
  end

  def remove_tag
    @tag = Tag.find params[:tag_id]
    @circle = Circle.find params[:circle_id]
    @circle.tags.delete(@tag)

    redirect_to marketing_dashboard_circles_path
  end


  private
  def load_circle
    authorize! :read, Circle

    @q    = @circles.includes(:tags).ransack(params[:q])
    @circles = @q.result.order('id DESC')

    respond_to do |format|
      format.html do
        @circles = @circles.paginate(paginate_params)
        render 'index'
      end
    end
  end


end

