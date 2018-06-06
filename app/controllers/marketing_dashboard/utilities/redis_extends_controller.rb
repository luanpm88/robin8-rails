class MarketingDashboard::Utilities::RedisExtendsController < MarketingDashboard::BaseController
  def ios_detail
  end

  def invite_switch
  end

  def update_redis_value
  	$redis.set(params[:key], params[:value])
    render js: "alert('更新成功');window.location.reload();"
  end

end