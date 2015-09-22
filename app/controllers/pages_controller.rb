class PagesController < ApplicationController
  # skip_before_filter :validate_subscription
  before_action :authenticate_user!, only: [:add_ons]
  before_action :set_video,:only => :home

  def set_locale
    unless params[:locale].blank?
      someone = current_user
      someone.update_attributes(locale: params[:locale]) unless someone.blank?
    end
    redirect_to root_path + "##{params[:current_page]}"
  end

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
    @products = Package.active.where "slug like 'new%'"
    render :layout => "website"
  end

  def add_ons
    @add_ons = AddOn.active
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
      flash.now[:success] = @l.t('contact_page.thank_you')
    end

    render :layout => "website"
  end

  def team
    render :layout => "website"
  end

  def about
    render :layout => "website"
  end

  def contact_us
    if is_china_request?
      render :file => "public/robin_cn.htm"
    else
      render :file => "public/robin.htm"
    end
  end

  def authenticate_user!
    if user_signed_in?
      redirect_to "/upgrade/#{params[:plan]}" if params[:plan].present? && current_user.active_subscription.present? && current_user.active_subscription.status == "A"
      redirect_to "/subscribe/#{params[:plan]}" if params[:plan].present? && current_user.active_subscription.present? && current_user.active_subscription.status == "C"
      super
    else
      session[:redirect_checkout_url] = "/add-ons?plan=#{params[:plan]}" if params[:plan].present?
      flash[:info] = "Please signup below and continue"
      return redirect_to new_user_path
    end
  end

  private
  def set_video
    if request.location && request.location.country.to_s == "China"
      @video = "<iframe src='http://player.youku.com/embed/XOTI2NzA2MTY0' frameborder='0' allowfullscreen></iframe>"
    else
      @video =  "<iframe src='//www.youtube.com/embed/Si6XnxuqhYI' frameborder='0' allowfullscreen></iframe>"
    end
  end

end
