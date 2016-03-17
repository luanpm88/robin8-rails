class BrandController < ApplicationController
  layout 'brand'
  def index
    @brand_home_props = { brand: current_user }
  end
end
