class PagesController < ApplicationController
  # skip_before_filter :validate_subscription
  before_action :authenticate_user!, only: [:add_ons]

  def home
    if user_signed_in? && !current_user.active_subscription.blank?
      render "home", :layout => 'application'
    elsif user_signed_in?
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
    @products = Product.package.active
    render :layout => "website"
  end

  def add_ons
    @add_ons = Product.active.add_on
    render :layout => "website"
  end

  def terms
    render :layout => "website"
  end

  def payment_confirmation
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

  def authenticate_user!
    if user_signed_in?
      super
    else
      session[:redirect_checkout_url] = "/add-ons?plan=#{params[:plan]}"
      flash[:info] = "Please signup below and continue"
      return redirect_to new_user_path
    end
  end

end
