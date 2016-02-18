class Brands::HomeController < ApplicationController
  layout :brand
  def index
    @user = {:name => "可口可乐"}
  end
end
