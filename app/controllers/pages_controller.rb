class PagesController < ApplicationController
  def home

  end

  def pricing
    @packages = Package.where(is_active: true)
    render :layout => false
  end

end
