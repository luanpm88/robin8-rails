# encoding: utf-8

module API
  module ApiHelpers
    PRIVATE_TOKEN_PARAM = :private_token
    EMAIL_REGEXP = /^([a-zA-Z0-9]+[_|\_|\.]+)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/

    def current_kol
      result , private_token = AuthToken.valid?(headers["Authorization"])
      if result
        @current_kol ||= Kol.app_auth(private_token)
        @current_kol
      end
    end

    #是否可以获取验证码
    def can_get_code?
      AuthToken.can_get_code?(headers["Authorization"])
    end

    def paginate(object)
      #paginate object
      object.page(params[:page]).per(params[:per_page].to_i)
    end

    def page_count(object)
      count = object/10
      count +=1 unless count * 10 == object
    end

    def authenticate!
      unauthorized! unless current_kol
    end

    def authenticate_from_engine!
      if headers["Authorization"] == 'search_engine'
        return true
      else
        error_403!('您无权限访问!')
      end
    end

    def user_avatar(user, style)
      if user and user.profile and user.profile.avatar?
        profile.avatar.url(style)
      end
    end

    def required_attributes!(keys)
      keys.each do |key|
        bad_request!(key) if params[key] != false && params[key].blank?
      end
    end

    def attribute_must_in(key, value, enum_values = [])
      if !enum_values.include?(value)
        bad_params_values(key, value, enum_values)
      end
    end


    def attributes_for_keys(keys)
      attrs = {}
      keys.each do |key|
        attrs[key] = params[key] if (params[key] and params[key].present?)
      end
      ActionController::Parameters.new(attrs).permit!
    end

    # error helpers
    def forbidden!
      render_api_error!('403 Forbidden', 403)
    end

    # 错误的属性
    def bad_request!(key)
      message = ["400 (Bad request)"]
      message << "\"" + key.inspect
      render_api_error!(message.join(' '), 400)
    end

    # 错误的属性值
    def bad_params_values(key, value, enum_values)
      message = ["400 (Bad request)"]
      message << "\" #{key} value: #{value} must in #{enum_values.inspect}"
      render_api_error!(message.join(' '), 400)
    end

    def not_found!(resource = nil)
      message = ["404"]
      message << resource if resource
      message << "Not Found"
      render_api_error!(message.join(' '), 404)
    end

    def unauthorized!
      render_api_error!('401 Unauthorized', 401)
    end

    def not_allowed!
      render_api_error!('Method Not Allowed', 405)
    end

    def internal_error!
      render_api_error!('Internal Server Error', 500)
    end

    def render_api_error!(message, status)
      error!({'detail' => message}, status)
    end

    def error_403!(message)
      error!(message, 403)
    end

    def errors_message(object)
      if object.errors.present?
        object.errors.messages.map { |e| e[1] } * ','
      end
    end

    def to_paginate(objs, per = 10)
      present :total_pages, objs.total_pages
      present :current_page, objs.current_page
      present :per_page, per
    end

    def clean_params(params)
      ActionController::Parameters.new(params).permit!
    end

    def logger
      API::Application.logger
    end

    def api_cache(*obj, ** options, &block)
      key = Digest::SHA1.hexdigest(obj.to_json)
      expires_in = options.delete(:expires_in) || 1.days
      present_cache(key: key, expires_in: expires_in, &block)
    end

    def phone_filter(campaigns)
      campaigns_filter = Array.new
      campaigns.each do |campaign|
        filter  = true
        targets = CampaignTarget.where(campaign_id: campaign[:id],
                                       target_type: %w(cell_phones td_promo admintags))
        if targets.present?
          targets.each do |target|
            index = case target[:target_type]
                    when "cell_phones"
                      [:mobile_number]
                    when "td_promo"
                      [:talkingdata_promotion_name]
                    when "admintags"
                      [:admintags, :first, :tag]
                    end
                    
            filter_result = if target[:target_type] == "admintags"
                              target[:target_content].split(",") & current_kol.admintags.map(&:tag)
                            else
                              target[:target_content].split(",").include?(index.inject(current_kol, :try))
                            end

            unless filter_result
            # unless target[:target_content].split(",").include?(index.inject(current_kol, :try))
              filter = false
              break
            end
=begin
            if target[:target_type] == "cell_phones"
              filter = false unless target[:target_content].split(",").index(current_kol[:mobile_number])
            elsif target[:target_type] == "td_promo"
              filter = false unless target[:target_content].split(",").index(current_kol[:talkingdata_promotion_name])
            end
=end
          end
        end
        campaigns_filter.push(campaign) if filter
      end
      campaigns_filter
    end

    def create_random_code
      SecureRandom.random_number(89999999)+10000000
    end

    def check_invite_code(code , kol_exist)
      code = code.to_s
      if code.size == 8
        return "邀请码仅限新用户使用"  if kol_exist
        return "无效的邀请码"  unless invite = KolInviteCode.find_by(code: code)
      elsif code.size == 6
        return "无效的邀请码"  unless invite = InviteCode.find_by(code: code)
      else
        return "无效的邀请码"
      end
      true
    end

    def update_social(params)
      # if params[:provider_name]
      #   provider = SocialAccount::Providers.invert[params[:provider_name]]
      # else
      #   provider = params[:provider]
      # end
      # return error_403!({error: 1, detail: 'provider_name 无效' })  unless SocialAccount::Providers.keys.include? provider
      # provider = SocialAccount::Providers.invert[provider]
      # 第三方登录时判断
      kol = Kol.find(params[:kol_id])
      # kol_name = params[:name]
      # 第三方登录时判断
      social_account = SocialAccount.find_or_initialize_by(:kol_id => kol.id , :provider => params[:provider])
      social_account.homepage = params[:homepage]  if params[:homepage].present?
      if params[:provider] == 'weibo' && social_account.homepage.blank?
        uid = kol.identities.where(:name => params[:name]).first.uid  rescue nil
        social_account.homepage = "http://m.weibo.cn/u/#{uid}"    if uid.present?
      end
      social_account.price = params[:price]                       if params[:price].present?
      social_account.username = params[:username]                 if params[:username].present?
      social_account.uid = params[:uid]                           if params[:uid].present?
      social_account.repost_price = params[:repost_price]         if params[:repost_price].present?
      social_account.second_price = params[:second_price]         if params[:second_price].present?
      social_account.followers_count = params[:followers_count]   if params[:followers_count].present?
      social_account.screenshot = params[:screenshot]             if params[:screenshot].present?
      social_account.save
    end


    def avatar_uploader(image = nil)
      return  unless image
      uploader = AvatarUploader.new
      uploader.store!(image)
      uploader.url
    end
  end
end
