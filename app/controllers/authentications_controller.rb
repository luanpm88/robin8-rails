class AuthenticationsController < Devise::OmniauthCallbacksController
  # :twitter, :linkedin, :facebook, :google_oauth2, :weibo, :wechat
  before_action :handle_omniauth_callback, only: [ :weibo, :wechat ]

  def weibo
    identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
    identity = Identity.find_by(:provider => params[:provider], :unionid => params[:unionid]) if identity.blank? and params[:unionid]

    if identity.blank?
      # create identity, redirect to register path
      Identity.create_identity_from_app(params.merge(:from_type => 'web'))
      # current_kol.update_attribute(:remote_avatar_url, params[:avatar_url])   if params[:avatar_url].present? && current_kol.avatar.url.blank?
    else
      # sign in and set union token
      user = identity.kol.user
      sign_in user # maybe change later !
      set_union_access_token
    end
  end

  # def wechat
  # end

  def failure
    p params
    flash[:error] = '出错了，请联系管理员'
    redirect_to root_path
  end

  private

  def handle_omniauth_callback
    auth = request.env['omniauth.auth']

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
  end
end
