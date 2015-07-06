class IptcCategoriesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @iptc_categories = IptcCategory.all
    
    respond_to do |format|
      format.json
    end
  end
  
  def show
    @iptc_category = IptcCategory.find(params[:id])
    
    respond_to do |format|
      format.json
    end
  end
end
