class MarketingDashboard::Utilities::RedisExtendsController < MarketingDashboard::BaseController
  def ios_detail
  end

  def invite_switch
  end

  def vest_bag_detail
  end

  def vote_switch
  end

  def reg_code
  end

  def update_redis_value
  	$redis.set(params[:key], params[:value])
    render js: "alert('更新成功');window.location.reload();"
  end

  def get_reg_code
    render js: "alert(#{$redis.get(params[:key])});"
  end

end