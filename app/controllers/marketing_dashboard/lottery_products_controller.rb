class MarketingDashboard::LotteryProductsController < MarketingDashboard::BaseController

  def index
    authorize! :read, LotteryActivity

    @lottery_products = LotteryProduct.order('created_at DESC').paginate(paginate_params)
  end

  def new
    authorize! :read, LotteryActivity

    @lottery_product = LotteryProduct.new
  end

  def edit
    authorize! :read, LotteryActivity

    @lottery_product = LotteryProduct.find(params[:id])
  end

  def create
    authorize! :update, LotteryActivity

    @lottery_product = LotteryProduct.new(lottery_product_params)

    params[:lottery_product][:posters].each do |picture|
      @lottery_product.posters.build(name: picture)
    end if params[:lottery_product][:posters].present?

    params[:lottery_product][:pictures].each do |picture|
      @lottery_product.pictures.build(name: picture)
    end if params[:lottery_product][:pictures].present?

    if @lottery_product.save
      redirect_to marketing_dashboard_lottery_product_path(@lottery_product)
    else
      render 'new'
    end
  end

  def update
    authorize! :update, LotteryActivity

    @lottery_product = LotteryProduct.find(params[:id])

    if params[:poster_id]
      @lottery_product.posters.where(id: params[:poster_id]).take.tap do |picture|
        picture.destroy
      end
      return render 'edit'
    end

    if params[:picture_id]
      @lottery_product.pictures.where(id: params[:picture_id]).take.tap do |picture|
        picture.destroy
      end
      return render 'edit'
    end

    params[:lottery_product][:posters].each do |picture|
      @lottery_product.posters.build(name: picture)
    end if params[:lottery_product][:posters].present?

    params[:lottery_product][:pictures].each do |picture|
      @lottery_product.pictures.build(name: picture)
    end if params[:lottery_product][:pictures].present?

    if @lottery_product.update!(lottery_product_params)
      redirect_to marketing_dashboard_lottery_products_path
    else
      render 'edit'
    end
  end

  def show
    authorize! :read, LotteryActivity

    @lottery_product = LotteryProduct.find(params[:id])
  end

  # def destroy
  #   @lottery_product = LotteryProduct.find params[:id]
  #   @lottery_product.destroy
  #   redirect_to action: :index
  # end

  def pub
    @lottery_product = LotteryProduct.find(params[:id])
    @lottery_product.pub
    redirect_to marketing_dashboard_lottery_products_path
  end

  private

  def lottery_product_params
    params.require(:lottery_product).permit(:name, :mode, :description, :quantity, :cover, :price)
  end
end
