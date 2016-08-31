class Mobile::BaseController < ApplicationController
  layout 'mobile'

  rescue_from CanCan::AccessDenied do |exception|
    render 'marketing_dashboard/errors/cancan_access_denied'
  end


end

