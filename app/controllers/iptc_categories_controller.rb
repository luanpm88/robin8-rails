class IptcCategoriesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @iptc_categories = IptcCategory.all
    
    respond_to do |format|
      format.json
    end
  end
end
