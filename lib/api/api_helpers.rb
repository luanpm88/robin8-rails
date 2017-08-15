# encoding: utf-8

module API
  module ApiHelpers
    PRIVATE_TOKEN_PARAM = :private_token

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

    def phone_filter(current_kol,campaigns)
      campaigns_filter = Array.new
      campaigns.each do |t|
        target = CampaignTarget.find_by("campaign_id" => t[:id] , "target_type" =>  "cell_phones")
        if target
          filter = target[:target_content].split(",").index(current_kol[:mobile_number])
          if filter
            campaigns_filter.push(t)
          end 
        else
          campaigns_filter.push(t)
        end
      end  
      campaigns_filter   
    end
  end
end
