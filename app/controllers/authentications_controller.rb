class AuthenticationsController < ApplicationController
  # :twitter, :linkedin, :facebook, :google_oauth2, :weibo, :wechat
  AUTH_ACTIONS = [ :weibo, :wechat, :qq_connect ]

  before_action :handle_omniauth_callback, only: AUTH_ACTIONS

  AUTH_ACTIONS.each do |action|
    define_method(action) do
      identity = Identity.find_by(provider: params[:provider], uid:     params[:uid])
      identity = Identity.find_by(provider: params[:provider], unionid: params[:unionid]) if identity.blank? and params[:unionid]
    
      if identity.blank?
        # create identity, redirect to register path
        if current_kol
          _identity = Identity.find_by(provider: params[:provider], kol_id:  current_kol.id) 
          params.merge!(kol_id: current_kol.id)
          identity = Identity.create_identity_from_app(params, _identity)
          return redirect_to omniauth_params['ok_url'] || brand_path
        else
          identity = Identity.create_identity_from_app(params)
          # For kol_pk use
          if omniauth_params['ok_url'].match(/kol_pk\/new\/vs/)
            new_kol = Kol.create(name: params[:name], identities: [identity])
            new_kol.update_column 'avatar_url', params[:avatar_url]
            set_union_access_token(new_kol)
            Rails.logger.kol_pk.info "--kol_pk /auth/weibo/callback: #{request.url}"
            return redirect_to omniauth_params['ok_url']
          end
          return redirect_to register_bind_path(identity_code: identity.id, ok_url: omniauth_params['ok_url'])
        end
      elsif identity.kol.nil?
        if current_kol
          params.merge!(kol_id: current_kol.id)
          identity.update(kol: current_kol)
          return redirect_to omniauth_params['ok_url'] || brand_path
        else
          # For kol_pk use
          if omniauth_params['ok_url'].match(/kol_pk\/new\/vs/)
            new_kol = Kol.create(name: params[:name], identities: [identity])
            new_kol.update_column 'avatar_url', params[:avatar_url]
            set_union_access_token(new_kol)
            Rails.logger.kol_pk.info "--kol_pk /auth/weibo/callback: #{request.url}"
            return redirect_to omniauth_params['ok_url']
          end
          return redirect_to register_bind_path(identity_code: identity.id, ok_url: omniauth_params['ok_url'])
        end
      else
        # sign in and set union token
        if current_kol
          return redirect_to append_query_params(omniauth_params['ok_url'], "bound=true")
        else
          kol = identity.kol
          user = kol.find_or_create_brand_user
          set_union_access_token(kol)
          return redirect_to omniauth_params['ok_url'] || brand_path
        end
      end
    end
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
        params = select_wechat_third_params(authorizer_info_package)
        @identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
        if @identity
          #此时提示转让公众号归属人
        else
          Identity.create_identity_from_app(params)
          redirect_to brand_path
        end
      end
    else
      render :json => {"result" => "failure"}.to_json
    end
  end

  def failure
    flash[:error] = '第三方授权登录出错了，请尝试其他方式登录'
    redirect_to login_url(params.permit(:ok_url))
  end

  private

  def handle_omniauth_callback
    auth = request.env['omniauth.auth']
    Rails.logger.alipay.info "-------- handle_omniauth_callback  --------------"
    Rails.logger.alipay.info "#{auth}"

    params[:uid] = auth.uid
    params[:provider] = (auth.provider == 'qq_connect') ? 'qq' : auth.provider
    params[:token] = auth.credentials.token
    params[:name] = (auth.provider == 'qq_connect' || auth.provider == 'wechat') ? auth.info.nickname : auth.info.name
    params[:email] = auth.info.email
    params[:avatar_url] = case auth.provider
                          when 'wechat'
                            auth.info.headimgurl
                          when 'qq_connect'
                            auth.extra.raw_info.figureurl_qq_2
                          else
                            auth.info.image
                          end
    params[:desc] = auth.info.description rescue nil
    params[:unionid] = auth.extra.raw_info.unionid rescue nil
    params[:province] = auth.extra.raw_info.province
    params[:city] = auth.extra.raw_info.city
    params[:gener] = auth.extra.raw_info.gender
    params[:url] = auth.provider == 'weibo' ? auth.info.urls[:Weibo] : nil
    params[:from_type] = 'web'
  end

  def omniauth_params
    request.env['omniauth.params']
  end

  def select_wechat_third_params(package)
    params[:uid] = package["authorization_info"]["authorizer_appid"]      rescue nil
    params[:provider] = 'wechat_third'
    params[:name] =  package["authorizer_info"]["nick_name"]         rescue nil
    params[:service_type_info] = package["authorizer_info"]["service_type_info"]["id"]    rescue nil
    params[:verify_type_info] = package["authorizer_info"]["verify_type_info"]["id"]      rescue nil
    params[:wx_user_name] = package["authorizer_info"]["user_name"]                       rescue nil
    params[:alias] = package["authorizer_info"]["alias"]
    params[:from_type] = 'web'
    params
  end

  def append_query_params(url, query_params)
    url.include?("?") ? (url + "&" + query_params) : (url + "?" + query_params)
  end

end
