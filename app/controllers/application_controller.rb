class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  rescue_from Exception, with: :handle_exception
  force_ssl if: :ssl_configured?

  after_filter :set_csrf_headers
  # before_filter :validate_subscription, unless: :devise_controller?
  before_filter :configure_permitted_parameters, if: :devise_controller?

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
                                                         :location, :is_public)
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
    !(Rails.env.development? or Rails.env.staging?)
  end
end
