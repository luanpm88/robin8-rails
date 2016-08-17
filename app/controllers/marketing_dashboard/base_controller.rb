class MarketingDashboard::BaseController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :current_admin_ability
  layout 'admin'

  def authorize!(*args)
    current_admin_ability.authorize!(*args)
  end

  def current_admin_ability
    current_ability ||= AdminAbility.new(current_admin_user)
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
end

class SearchHelper
  include Mongoid::Document
  include Mongoid::Timestamps
  field :key, type: String
  field :item_type, type: String
end
