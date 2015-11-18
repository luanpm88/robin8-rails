module WxThird
  class Util
    Domain = Rails.application.secrets[:domain]
    State = '11223312abcdfefewf'
    AppId = Rails.application.secrets[:wechat_third][:app_id]
    AppSecret = Rails.application.secrets[:wechat_third][:app_secret]
    AesKey = Rails.application.secrets[:wechat_third][:aes_key]
    DescryToken = Rails.application.secrets[:wechat_third][:descry_token]
    ComponentTokenUrl =  'https://api.weixin.qq.com/cgi-bin/component/api_component_token'

    class << self
      preuth_code_url = lambda{|access_token|"https://api.weixin.qq.com/cgi-bin/component/api_create_preauthcode?component_access_token=#{access_token}"}
      query_auth_url = lambda{|access_token| "https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token=#{access_token}"}
      get_authorizer_info = lambda{|access_token|"https://api.weixin.qq.com/cgi-bin/component/api_get_authorizer_info?component_access_token=#{access_token}" }

      # 保存 component_verify_ticket 的key
      def component_verify_ticket_key(appid)
        appid + "_component_verify_ticket"
      end

      # 保存 component_access_token 的key
      def component_access_token_key(appid)
        appid + "_component_access_token"
      end

      # 保存 get_pre_auth_code 的key
      def pre_auth_code_key(nowAppId)
        nowAppId + "_pre_auth_code"
      end

      #）授权公众号的令牌 key
      def authorizer_access_token_key(authorizer_appid)
        authorizer_appid + "_authorizer_access_token"
      end

      # 获取第三方平台令牌（component_access_token）
      def get_component_access_token
        component_access_token = Rails.cache.read(component_access_token_key(AppId))
        return component_access_token     if component_access_token.present?
        postData = {"component_appid" => AppId, "component_appsecret" => AppSecret,
                    "component_verify_ticket" => Rails.cache.read(component_verify_ticket_key(AppId))}
        res = RestClient::post(ComponentTokenUrl, postData.to_json)
        # 解析返回的数据
        retData = JSON.parse(res.body)
        p "get_component_access_token:retData->"+retData.to_s
        return nil if retData['errorcode']
        component_access_token = retData["component_access_token"]
        expiresIn = retData["expires_in"]
        Rails.cache.write(component_access_token_key(AppId), component_access_token, expires_in: expiresIn.to_i - 60 )
        component_access_token
      end


      # 获取预授权码
      def get_pre_auth_code
        pre_auth_code = Rails.cache.read(pre_auth_code_key(AppId))
        return pre_auth_code if pre_auth_code.present?
        component_access_token = get_component_access_token
        return nil if component_access_token.blank?
        postData = {"component_appid" => SHAKE_APPID}
        res = RestClient::post(preuth_code_url.call(component_access_token), postData.to_json)
        retData = JSON.parse(res.body)
        p "get_pre_auth_code:retData -->"+retData.to_s
        pre_auth_code = retData["pre_auth_code"]
        pre_auth_code_expiresIn = retData["expires_in"]
        p "get_pre_auth_code ->pre_auth_code:#{pre_auth_code}  preAuthCodeExpiresIn:#{pre_auth_code_expiresIn}"
        #保存新的 pre_auth_code
        Rails.cache.write(pre_auth_code_key(SHAKE_APPID), pre_auth_code, :expires_in => pre_auth_code_expiresIn.to_i - 60)
        pre_auth_code
      end


      # 使用授权码换取公众号的授权信息
      def query_auth_info(auth_code)
        component_access_token = get_component_access_token
        post_data = {"component_appid" => AppId, "authorization_code" => auth_code}
        ret = RestClient::post(query_auth_url.call(component_access_token), post_data.to_json)
        return JSON.parse(ret.body)
      end

      # 查询已授权公众账号的详细信息
      def get_authorizer_info(authorizer_appid)
        component_access_token = get_component_access_token
        return nil if   component_access_token.blank?
        post_data = {"component_appid"=> AppId, "authorizer_appid"=> authorizer_appid}
        res = RestClient::post(get_authorizer_info.call(post_data),post_data.to_json)
        JSON.parse(res.body)
      end

      # 登陆 跳转
      def loginpage_url(pre_auth_code = nil)
        pre_auth_code = get_pre_auth_code if pre_auth_code.blank?
        redirectUri = "#{Domain}/users/auth/wechat_third_callback"
        return "https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{AppId}&pre_auth_code=#{pre_auth_code}&redirect_uri=#{redirectUri}"
      end

    end
  end
end
