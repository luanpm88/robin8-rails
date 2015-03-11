class PagesController < ApplicationController
  # skip_before_filter :validate_subscription
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

  def terms
    render :layout => "website"
  end

  def contact
    if request.post?
      UserMailer.contact_support(params[:user]).deliver if params[:user].present?
      flash.now[:success] = "Thank you for contacting us. Someone from our team will contact you shortly"
    end

    render :layout => "website"
  end

  def team
    render :layout => "website"
  end

  def about
    render :layout => "website"
  end

end
