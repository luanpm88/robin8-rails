class MarketingDashboard::EWallets::RedisSetsController < MarketingDashboard::BaseController

  def sales
  	
  end

  def update_sales
  	$redis.set(params[:key], params[:value])
    render js: "alert('更新成功');window.location.reload();"
  end

end