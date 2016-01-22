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

    def paginate(object)
      #paginate object
      object.page(params[:page]).per(params[:per_page].to_i)
    end

    def authenticate!
      unauthorized! unless current_user
    end

    def user_avatar(user, style)
      if user and user.profile and user.profile.avatar?
        profile.avatar.url(style)
      end
    end

    # Checks the occurrences of required attributes, each attribute must be present in the params hash
    # or a Bad Request error is invoked.
    #
    # Parameters:
    #   keys (required) - A hash consisting of keys that must be present
    def required_attributes!(keys)
      keys.each do |key|
        bad_request!(key) if params[key].blank?
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

    def bad_request!(key)
      message = ["400 (Bad request)"]
      message << "\"" + key.inspect
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

  end
end
