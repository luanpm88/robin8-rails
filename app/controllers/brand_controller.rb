class BrandController < ApplicationController
  layout 'brand'
  def index
    sign_in User.find(642)
    @brand_home_props = { brand: current_user }
  end
end
