class MarketingDashboard::BaseController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :current_admin_ability
  before_action :set_locale
  layout 'admin'


  def set_locale
    session[:locale] = params[:locale]  if  params[:locale].present?
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def current_admin_ability
    #TODO cache current_ability
    @current_ability ||= AdminAbility.new(current_admin_user)
  end

  def can?(*args)
    current_admin_ability.can?(*args)
  end

  def authorize!(*args)
    current_admin_ability.authorize!(*args)
  end

  rescue_from CanCan::AccessDenied do |exception|
    render 'marketing_dashboard/errors/cancan_access_denied'
  end


  private
  def paginate_params
    {
      :page => params[:page] || 1,
      :per_page => params[:per_page] || 20
    }
  end

  # {"(1i)"=>"2018", "(2i)"=>"1", "(3i)"=>"18"}
  def format_date(args)
    Time.parse args.values.join('-')
  end
end

class SearchHelper
  include Mongoid::Document
  include Mongoid::Timestamps
  field :key, type: String
  field :item_type, type: String
end
