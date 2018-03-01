require File.expand_path('../wx_util',__FILE__)
module WxThird
  class Auth
    class << self
      #appid  公众号的appid,   component_appid	是	服务方的appid
      def auth_url(appid, scope="snsapi_userinfo")
        redirect_uri = "#{Domain}/webchat_third/callback"
        auth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=#{scope}&state=#{STATE}&component_appid=#{AppId}#wechat_redirect"
      end

      #通过code换取access_token 等等信息
      def get_app_auth_info(appid, code)
        component_access_token = Util.get_component_access_token
        url = "https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{appid}&code=#{code}&grant_type=authorization_code&component_appid=#{AppId}&component_access_token=#{component_access_token}"
        res = RestClient::get(url)
        JSON.parse(res.body)

        Rails.logger.wechat.info "===wxthird===appid===#{appid}===code===#{code}===body===#{JSON.parse(res.body)}"
      end


      #刷新access_token
      def refresh_app_auth_access_token(appid, refresh_token)
        return if appid.nil? || refresh_token.nil?
        url = "https://api.weixin.qq.com/sns/oauth2/component/refresh_token?appid=#{appid}&grant_type=refresh_token&component_appid=#{AppId}&component_access_token=#{WxUtil.get_component_access_token}&refresh_token=#{refresh_token}"
        res = RestClient::get(url)
        ret = JSON.parse(res.body)
        p "refresh_app_auth_access_token = #{ret.to_s}"

        Rails.logger.wechat.info "===wxthird===appid===#{appid}===refresh_token===#{refresh_token}===body===#{ret}"

        if ret
          access_token = ret["access_token"]
          expires_in = ret["expires_in"].to_i
          new_refresh_token = ret["refresh_token"]
          openid = ret["openid"]
          scope = ret["scope"]
        end
      end


      #通过网页授权access_token获取用户基本信息（需授权作用域为snsapi_userinfo）
      def get_user_info(openid, access_token)
        return if openid.nil? || access_token.nil?
        url = "https://api.weixin.qq.com/sns/userinfo?access_token=#{access_token}&openid=#{openid}&lang=zh_CN"
        res = RestClient::get(url)
        ret = JSON.parse(res.body)
      end

      def app_access_token_key(appid)
        "#{appid}_app_access_token_key"
      end
    end
  end
end
