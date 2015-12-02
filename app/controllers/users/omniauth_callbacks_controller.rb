module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # TODO: perhaps we should get rid of this code generation, it's useless
    # here
    def self.provides_callback_for(provider)
      class_eval %Q{
        def #{provider}
          auth = request.env['omniauth.auth']

          if Rails.env.development?
            puts "Got following auth info:"
            puts auth.to_yaml
          end

          params = {}
          params[:uid] = auth.uid
          params[:provider] = auth.provider
          params[:token] = auth.credentials.token
          params[:token_secret] = auth.credentials.secret
          params[:name] = (auth.provider == 'twitter' || auth.provider == 'wechat') ? auth.info.nickname : auth.info.name
          params[:email] = auth.info.email
          params[:avatar_url] = (auth.provider == 'wechat') ? auth.info.headimgurl : auth.info.image rescue nil
          params[:desc] = auth.info.description rescue nil
          params[:unionid] = auth.extra.raw_info.unionid rescue nil

          params[:url] = case auth.provider
          when 'facebook'
            auth.extra.raw_info.link
          when 'google_oauth2'
            auth.extra.raw_info.profile
          when 'twitter'
            auth.info.urls[:Twitter]
          when 'linkedin'
            auth.info.urls.public_profile
          when 'weibo'
            auth.info.urls[:Weibo]
          end

          save_callback_info(params,auth)
        end
      }
    end

    def failure
      p params
      render 'twitter_popup_close', :layout => false
    end

    [:twitter, :linkedin, :facebook, :google_oauth2, :weibo, :wechat].each do |provider|
      provides_callback_for provider
    end

    def wechat_third
      redirect_to WxThird::Util.loginpage_url
    end

    def wechat_third_callback
      auth_code = params["auth_code"]
      if auth_code
        #查询公众号的授权信息
        auth_info = WxThird::Util.query_auth_info(auth_code)
        p "auth_info = " + auth_info.to_s
        authorization_info = auth_info["authorization_info"]
        #授权成功
        if authorization_info && authorization_info.has_key?("authorizer_access_token")
          authorizer_appid = authorization_info["authorizer_appid"]
          # 获取授权公众账号的信息
          authorizer_info_package = WxThird::Util.get_authorizer_info(authorizer_appid)
          p "authorizer_info ==== #{authorizer_info_package.to_json}"
          params = Identity.switch_package_to_params(authorizer_info_package)
          save_callback_info(params, authorizer_info_package)
        end
      else
        render :json => {"result" => "failure"}.to_json
      end
    end


    private
    def save_callback_info(params, origin_auth)
      if current_user.nil? and current_kol.nil?
        someone = User
        if cookies[:kol_social] == "yeah"
          someone = Kol
          cookies[:kol_social] = "no"
        end
        @someone = someone.find_for_oauth(params)
        if @someone
          cookies[:kol_signin] = "no"
          sign_in @someone
          if @someone.class == Kol
            cookies[:kol_signin] = "yeah"
          end
        else
          Rails.cache.write("auth_params", params, expires_in: 30.minute)
          return redirect_to kols_new_path(auth_params: true)
        end
      else
        @identity = Identity.find_for_oauth(params, origin_auth, current_kol)
        if current_kol.nil?
          if @identity.user != current_user
            @identity.user = current_user
            @identity.kol_id = nil
            @identity.save
          end
        else
          if @identity.kol != current_kol
            @identity.kol = current_kol
            @identity.user_id = nil
            @identity.save
          end
        end
      end
      if (!china_instance? && request.env['omniauth.params'].blank?) || (china_instance? && cookies[:popup_signin] == 'yeah')
        cookies[:popup_signin] = nil
        render 'twitter_popup_close', :layout => false
      else
        redirect_to root_path
      end
    end
  end
end
