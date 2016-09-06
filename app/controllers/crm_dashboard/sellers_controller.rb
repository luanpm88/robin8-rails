class CrmDashboard::SellersController < CrmDashboard::BaseController

  def index
    @sellers = Crm::Seller.all.order('created_at DESC').paginate(paginate_params)
  end

  def new
    @seller = Crm::Seller.new
  end

  def create
    @seller = Crm::Seller.new(seller_params.merge(password_confirmation: params[:seller][:password], private_token: SecureRandom.hex))
    if @seller.save
      flash[:notice] = "创建成功"
      redirect_to action: :index
    else
      flash[:alert] = "创建失败, 请重试. 注意: 账户名为手机号码，密码要大于6位, 账户名称不能重复"
      render :new
    end
  end

  def edit
    @seller = Crm::Seller.find(params[:id])
  end

  def update
    @seller = Crm::Seller.find(params[:id])
    @seller.update_attributes(seller_params.merge(password_confirmation: params[:seller][:password], private_token: SecureRandom.hex))
    if @seller.errors.empty?
      flash[:notice] = "修改成功"
      redirect_to action: :index
    else
      flash[:alert] = "修改失败, 请重试. 注意: 账户名为手机号码，密码要大于6位, 账户名称不能重复"
      render :edit
    end
  end

  def destroy
    @seller = Crm::Seller.find(params[:id])
    @seller.delete
    if @seller.destroyed?
      flash[:notice] = "删除成功"
      redirect_to action: :index
    else
      flash[:alert] = "删除失败，请重试"
    end
  end

  def customers
    @seller = Crm::Seller.find(params[:id])
    @customers = @seller.customers.order('created_at DESC').paginate(paginate_params)
  end

  def orders
    @seller = Crm::Seller.find(params[:id])
    @orders = AlipayOrder.where(invite_code: @seller.invite_code).order('created_at DESC').paginate(paginate_params)
  end

  private

  def seller_params
    params.require(:seller).permit(:mobile_number, :name, :department, :avatar, :invite_code, :password)
  end
end
