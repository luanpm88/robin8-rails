class MarketingDashboard::SocialAccountsController < MarketingDashboard::BaseController
  def index
    @social_accounts = SocialAccount.where(:kol_id => params[:kol_id])
  end

  def new
    @social_account = SocialAccount.new
    @social_account.kol_id = params[:kol_id]
  end

  def create
    @social_account = SocialAccount.new(permit_params)
    @social_account.kol_id = params[:kol_id]
    if @social_account.save
      flash[:notice] = "创建成功"
      redirect_to marketing_dashboard_social_accounts_path(:kol_id => params[:kol_id])
    else
      flash[:notice] = @social_account.errors.messages.values.flatten.join("\n")
      render :new
    end
  end

  def permit_params
    params.require(:social_account).permit(:kol_id, :provider, :username,
         :homepage, :avatar_url, :brief, :like_count, :followers_count, :friends_count,
          :reposts_count, :statuses_count, :verified, :province, :city, :gender, :price, :second_price, :repost_price)
  end
end