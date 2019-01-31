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
    if request.get?
    else
      if params[:login].match(Brand::V2::APIHelpers::EMAIL_REGEXP)
        code = $redis.get("valid_#{params[:login]}")
      elsif params[:login].match(Brand::V2::APIHelpers::MOBILE_NUMBER_REGEXP)
        code = YunPian::SendRegisterSms.get_code(params[:login])
      end
      if code.present?
        render js: "alert(#{code});window.location.reload();"
      else
        render js: "alert('数据有误');window.location.reload();"
      end
    end
  end

  def update_redis_value
  	$redis.set(params[:key], params[:value])
    render js: "alert('更新成功');window.location.reload();"
  end

  def get_reg_code
    render js: "alert(#{$redis.get(params[:key])});"
  end

end