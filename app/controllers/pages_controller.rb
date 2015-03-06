class PagesController < ApplicationController
  skip_before_filter :validate_subscription

  def home
    if signed_in?
      render "home", :layout => 'application'
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
