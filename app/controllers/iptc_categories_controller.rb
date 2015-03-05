class IptcCategoriesController < ApplicationController
  def index
    @iptc_categories = IptcCategory.all
    
    respond_to do |format|
      format.json
    end
  end
end
