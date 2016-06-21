class MarketingDashboard::BaseController < ApplicationController
  before_action :authenticate_admin_user!
  layout 'admin'

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

