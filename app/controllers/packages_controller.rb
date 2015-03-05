class PackagesController < ApplicationController
  def index
    @packages = Package.where(is_active: true)
    render json: @packages
  end
end
