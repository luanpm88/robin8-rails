class AuthenticationsController < ApplicationController
  # :twitter, :linkedin, :facebook, :google_oauth2, :weibo, :wechat
  before_action :handle_omniauth_callback, only: [ :weibo, :wechat, :qq_connect ]

  def weibo
    identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
    identity = Identity.find_by(:provider => params[:provider], :unionid => params[:unionid]) if identity.blank? and params[:unionid]

    if identity.blank?
      # create identity, redirect to register path
      identity_params = params.merge(:from_type => 'web')
      identity_params.merge!(kol_id: current_kol.id) if current_kol
      identity = Identity.create_identity_from_app(identity_params)
      redirect_to omniauth_params['ok_url'] || root_path(identity_code: identity.id) #重定向到 注册页面
    else
      # sign in and set union token
      user = identity.kol.find_or_create_brand_user
      sign_in user # maybe change later !
      set_union_access_token
      redirect_to omniauth_params['ok_url'] || root_path
    end
  end

  def wechat
    identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
    identity = Identity.find_by(:provider => params[:provider], :unionid => params[:unionid]) if identity.blank? and params[:unionid]

    if identity.blank?
      # create identity, redirect to register path
      identity_params = params.merge(:from_type => 'web')
      identity_params.merge!(kol_id: current_kol.id) if current_kol
      identity = Identity.create_identity_from_app(identity_params)
      redirect_to cookies.delete(:return_url) || root_path(identity_code: identity.id) #重定向到 注册页面
    else
      # sign in and set union token
      user = identity.kol.find_or_create_brand_user
      sign_in user # maybe change later !
      set_union_access_token
      redirect_to cookies.delete(:return_url) || root_path
    end
  end

  def qq_connect
    identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
    identity = Identity.find_by(:provider => params[:provider], :unionid => params[:unionid]) if identity.blank? and params[:unionid]

    if identity.blank?
      # create identity, redirect to register path
      identity_params = params.merge(:from_type => 'web')
      identity_params.merge!(kol_id: current_kol.id) if current_kol
      identity = Identity.create_identity_from_app(identity_params)
      redirect_to cookies.delete(:return_url) || root_path(identity_code: identity.id) #重定向到 注册页面
    else
      # sign in and set union token
      user = identity.kol.find_or_create_brand_user
      sign_in user # maybe change later !
      set_union_access_token
      redirect_to cookies.delete(:return_url) || root_path
    end
  end

  def failure
    p params
    flash[:error] = '出错了，请联系管理员'
    redirect_to root_path
  end

  private

  def handle_omniauth_callback
    auth = request.env['omniauth.auth']
    Rails.logger.alipay.info "-------- handle_omniauth_callback  --------------"
    Rails.logger.alipay.info "#{auth}"

    params[:uid] = auth.uid
    params[:provider] = auth.provider
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
  end

  def omniauth_params
    request.env['omniauth.params']
  end
end
