class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:pricing]
  def home
    if signed_in? && current_user.subscriptions.length > 0
      render "home", :layout => 'application'
    elsif signed_in?
      redirect_to pricing_path
    else
      render "landing_page", :layout => 'landing'
    end
  end

  def singup
    render "home", :layout => 'application'
  end

  def signin
    render "home", :layout => 'application'
  end

  def pricing
    @packages = Package.where(is_active: true)
    render :layout => "website"
  end

end
