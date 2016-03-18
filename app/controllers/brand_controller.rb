class BrandController < ApplicationController
  layout 'brand'
  def index
    sign_in User.first
    @brand_home_props = { brand: current_user }
  end
end
