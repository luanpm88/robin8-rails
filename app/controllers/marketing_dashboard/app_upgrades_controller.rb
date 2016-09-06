class MarketingDashboard::AppUpgradesController < MarketingDashboard::BaseController

  def index
    authorize! :read, AppUpgrade
    @app_upgrades  = AppUpgrade.order("app_version desc")
  end

  def new
    authorize! :read, AppUpgrade
    @app_upgrade = AppUpgrade.new
  end

  def create
    authorize! :update, AppUpgrade
    params.permit!
    @app_upgrade =  AppUpgrade.new(params[:app_upgrade])
    @app_upgrade.release_at = Time.now
    if @app_upgrade.save
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def edit
    authorize! :update, AppUpgrade
    @app_upgrade = AppUpgrade.find params[:id]
  end

  def update
    authorize! :update, AppUpgrade
    params.permit!
    @app_upgrade = AppUpgrade.find params[:id]
    if @app_upgrade.update_attributes(params[:app_upgrade])
      flash[:notcie] = '更新成功'
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

  def destroy
    authorize! :update, AppUpgrade
    @app_upgrade = AppUpgrade.find params[:id]
    @app_upgrade.destroy
    redirect_to :action => :index
  end

  def switch
    authorize! :update, AppUpgrade
    @app_upgrade = AppUpgrade.find params[:id]
    @app_upgrade.update_column(:force_upgrade, !@app_upgrade.force_upgrade)
    flash[:notce] = "操作成功!"
    redirect_to :action => :index
  end

end
