class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:account_update).push(:first_name, :last_name, :company, :time_zone, :name)
    end

    def set_paginate_headers klass, count
      response.headers["totalCount"] = count.to_s
      response.headers["totalPages"] = (count.to_f/(params[:per_page].nil? ? klass.per_page : params[:per_page].to_i)).ceil.to_s
    end
end
