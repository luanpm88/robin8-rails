class MarketingDashboard::EWallets::PromotionsController < MarketingDashboard::BaseController

  def index
    @promotions = EWallet::Promotion.all
    load_promotions
  end

  def new
    @promotion = EWallet::Promotion.new
  end

  def create 
    @promotion = EWallet::Promotion.new(promotion_params)

    if @promotion.save!
      flash[:notice] = '创建成功'
      redirect_to marketing_dashboard_e_wallets_promotions_path
    else
      flash[:alert] = '创建失败'
      render :new
    end
  end





  private 

  def load_promotions
    authorize! :read, EWallet::Promotion

    @q    = @promotions.ransack(params[:q])
    @promotions = @q.result.order('id DESC')

    respond_to do |format|
      format.html do
        @promotions = @promotions.paginate(paginate_params)
        render 'index'
      end

    end
  end

    def promotion_params
    _hash = params[:e_wallet_promotion].permit!

    _hash[:extra_percentage] = _hash[:extra_percentage].to_f/100

    _hash
  end

end
