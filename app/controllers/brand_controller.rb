class BrandController < ApplicationController
  layout 'brand'
  def index
    unless current_user
      sign_in User.first
    end
    @brand_home_props = { brand: current_user }
  end
end
