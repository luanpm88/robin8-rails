class MarketingDashboard::HotItemsController < MarketingDashboard::BaseController
  def index
    @hot_items = HotItem.all.order("publish_at desc").paginate(paginate_params)
  end

  def new
    @hot_item = HotItem.new
  end

  def create
    @hot_item = HotItem.new(params[:hot_item].permit!)
    if @hot_item.save
      redirect_to marketing_dashboard_hot_items_url
    else
      flash[:alert] = @hot_item.errors.messages.values.flatten.join("\n")
      render :new
    end
  end

  def destroy
    @hot_item = HotItem.find params[:id]
    @hot_item.delete
    flash[:notice] = '删除成功'
    redirect_to marketing_dashboard_hot_items_url
  end


end
