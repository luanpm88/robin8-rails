class WechatThirdController < ApplicationController
  def auth_login
    preAuthCode = WxThird::Util.get_pre_auth_code
    if preAuthCode
      componentloginpageUrl = "https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{SHAKE_APPID}&pre_auth_code=#{preAuthCode}"
      #redirectUri = URI.escape("http://j.51self.com/auth/callback")
      redirectUri = "#{SHAKE_DOMAIN}/auth/callback"
      componentloginpageUrl += "&redirect_uri=#{redirectUri}"
      redirect_to componentloginpageUrl
      return
    end
    render :text => "error"
  end

  def callback
    puts params
    if prams[:code].blank?
      puts "-----用户禁止授权"
      return
    else
      WxThird.
    end
  end
end
