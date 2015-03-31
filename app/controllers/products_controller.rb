class ProductsController < ApplicationController
  def index
    @products = Product.active.packages
    render json: @products
  end
end
