class MarketingDashboard::Utilities::SettingsController < MarketingDashboard::BaseController
  def index
  end

  def update_value
    MySettings.send("#{params[:key]}=", params[:value].to_i)
    render :js => "alert('更新成功');window.location.reload();"
  end
end
