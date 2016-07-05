class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Concerns::BrowserRequest
  before_filter :set_cookies
  before_filter :set_utm_source
  before_action :set_translations
  helper_method :china_instance?
  helper_method :china_request?
  helper_method :china_locale?
  helper_method :mobile_request?
  helper_method :production?

  protect_from_forgery with: :exception
  rescue_from Exception, with: :handle_exception
  force_ssl if: :ssl_configured?

  after_filter :set_csrf_headers
  # before_filter :validate_subscription, unless: :devise_controller?
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def set_utm_source
    if utm_source = params[:utm_source]
      cookies['utm_source'] = { value: utm_source, expires: 1.day.from_now }
    end
  end

  def set_cookies
    cookies[:_robin8_visitor] ||= SecureRandom.hex
  end

  def set_union_access_token
    return unless current_user.kol
    cookies.permanent[:_robin8_union] = {
      value: current_user.kol.union_access_token.token,
      domain: :all
    }
  end

  def is_china_request?
    return true
  end
  alias_method :china_request?, :is_china_request?

  def production?
    Rails.env.production?
  end

  def set_translations
    default_locale = china_instance? ? 'zh' : 'en'
    if  current_user.present? ||  current_kol.present?
      someone = current_user  ||  current_kol
      if params[:locale] && [:en, :zh].include?(params[:locale].to_sym)
        someone.update_column(:locale, params[:locale])
      end
      locale = someone.locale || cookies['locale']  || default_locale
    else
      if params[:locale] && [:en, :zh].include?(params[:locale].to_sym)
        cookies['locale'] = { value: params[:locale], expires: 1.year.from_now }
        I18n.locale = params[:locale].to_sym
      elsif cookies['locale'] && [:en, :zh].include?(cookies['locale'].to_sym)
        I18n.locale = cookies['locale'].to_sym
      else
        I18n.locale = default_locale
        cookies['locale'] = { value: I18n.locale, expires: 1.year.from_now }
      end
      locale = I18n.locale
    end
    @l ||= Localization.new
    @l.locale = locale

    if @l.store.get(locale)
      @phrases ||=  JSON.parse(@l.store.get(locale))['application']    rescue {}
    end
    @en_phrases ||=  JSON.parse(@l.store.get("en"))['application']     rescue {}
  end

  def china_locale?
    @l.locale.to_sym  == :'zh' ? true : false        rescue false
  end

  ActiveAdmin::ResourceController.class_eval do
    def find_resource
      resource_class.is_a?(FriendlyId) ? scoped_collection.where(slug: params[:id]).first! : scoped_collection.where(id: params[:id]).first!
    end
  end

  def validate_subscription
    if user_signed_in?
      flash[:alert] = "You need an active subscription to continue"; return redirect_to :pricing if current_user.active_subscription.blank?
    end
  end

  def set_csrf_headers
    response.headers['X-CSRF-Token'] = form_authenticity_token if protect_against_forgery?
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name)
    devise_parameter_sanitizer.for(:account_update).push(:first_name,
                                                         :last_name, :company, :time_zone, :name, :avatar_url,
                                                         :location, :is_public, :date_of_birthday, :industry, :title, :mobile_number,
                                                         :gender, :country, :province, :city, :audience_gender_ratio, :audience_age_groups,
                                                         :wechat_personal_fans, :wechat_public_name, :wechat_public_id, :wechat_public_fans,
                                                         :audience_regions)
    devise_parameter_sanitizer.for(:invite).push(:is_primary)
  end

  def set_paginate_headers klass, count
    response.headers["totalCount"] = count.to_s
    response.headers["totalPages"] = (count.to_f/(params[:per_page].nil? ? klass.per_page : params[:per_page].to_i)).ceil.to_s
  end

  def handle_exception(e)
    if Rails.env.development?
      logger.error e.message
      logger.error e.backtrace.join("\n")
    end
    case e
      when ActiveRecord::RecordNotFound
        render :json => {error: "404 Not Found", message: e.message}, status: 404
      when ActiveRecord::RecordNotUnique
        render :json => {error: "400 Bad Request", message: e.message}, status: 400
      when ActiveRecord::RecordInvalid
        render :json => {error: "422 Unprocessable Entity", message: e.message}, status: 422
      when ActiveModel::ForbiddenAttributesError
        render :json => {error: "422 Unprocessable Entity", message: e.message}, status: 422
      when ActionController::ParameterMissing
        render json: { error: "400 Bad Request", message: e.message }, status: 400
      else
        render :json => {error: "500 Internal Server Error", message: e.message}, status: 500
    end
  end

  private

  def ssl_configured?
    false
  end

  def china_instance?
    Rails.application.config.china_instance
  end

  def china_client?
    return true
  end
end
