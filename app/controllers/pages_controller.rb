class PagesController < ApplicationController
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
end
