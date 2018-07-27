class MarketingDashboard::EWallets::KolPromotionsController < MarketingDashboard::BaseController
  before_filter :get_kol_promotion, only: [:edit, :update, :show, :destroy, :modify_state]

  def index
    @kol_promotions = EWallet::KolPromotion.all
    load_promotions
  end

  def new
    @kol_promotion = EWallet::KolPromotion.new
  end

  def create 
    @kol_promotion = EWallet::KolPromotion.new(kol_promotion_params)

    if @kol_promotion.save!
      flash[:notice] = '创建成功'
      redirect_to marketing_dashboard_e_wallets_kol_promotions_path
    else
      flash[:alert] = '创建失败'
      render :new
    end
  end

  def edit
  end

  def show
  end

  def update
    if @kol_promotion.update_attributes!(kol_promotion_params)
      flash[:notice] = '更新成功'
      redirect_to marketing_dashboard_e_wallets_kol_promotions_path
    else
      flash[:alert] = '更新失败'
      render :edit
    end
  end

  def destroy
    @kol_promotion.destroy
    redirect_to :action => :index
  end

  def modify_state
    if @kol_promotion.update_attributes!(state: 0)
      flash[:notice] = '下架成功'
    else
      flash[:alert] = '下架失败'
    end
    redirect_to marketing_dashboard_e_wallets_kol_promotions_path
  end



  private 

  def load_promotions
    authorize! :read, EWallet::KolPromotion

    @q    = @kol_promotions.ransack(params[:q])
    @kol_promotions = @q.result.order('id DESC')

    respond_to do |format|
      format.html do
        @kol_promotions = @kol_promotions.paginate(paginate_params)
        render 'index'
      end

    end
  end

  def kol_promotion_params
    _hash = params[:e_wallet_kol_promotion].permit!
    _hash[:extra_percentage] = _hash[:extra_percentage].to_f
    _hash
  end

  def get_kol_promotion
    @kol_promotion = EWallet::KolPromotion.find params[:id]
  end

end
