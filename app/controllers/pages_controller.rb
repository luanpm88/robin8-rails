class PagesController < ApplicationController
  # skip_before_filter :validate_subscription
  before_action :authenticate_user!, only: [:add_ons]
  before_action :authenticate_kol!, only: [:withdraw_apply]
  before_action :set_video,:only => [:home,:landing_page_brand]

  def set_locale
    unless params[:locale].blank?
      someone = current_user
      someone = current_kol if current_user.nil?
      someone.update_attributes(locale: params[:locale]) unless someone.blank?
    end
    redirect_to root_path + "##{params[:current_page]}"
  end

  def home
    if user_signed_in? && !current_user.active_subscription.blank?
      render "home", :layout => 'application'
    elsif user_signed_in?
      render "home", :layout => 'application'
    elsif kol_signed_in?
      if current_kol.confirmed_at == nil && current_kol.provider == 'signup'
        flash[:confirmation_alert] = @l.t('dashboard.check_to_activate')
      end

      to_verify_count = current_kol.campaign_invites.where(status: 'finished', img_status: 'pending').where.not(screenshot: nil).count
      verify_failed_count = current_kol.campaign_invites.where(status: 'finished', img_status: 'rejected').count

      if to_verify_count>0 or verify_failed_count>0
        flash[:verify_count] = {
          :to_verify_count => to_verify_count,
          :verify_failed_count => verify_failed_count
        }
      end

      render "home", :layout => 'kol'
    else
      render "landing_page", :layout => 'landing'
    end
  end

  def landing_page_brand
    render "landing_page_brand", :layout => 'landing'
  end

  def singup
    render "home", :layout => 'application'
  end

  def signin
    render "home", :layout => 'application'
  end

  def pricing
    # 暂时注释掉
    #@products = Package.active.where "slug like 'new%'"
    @products = Package.all
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
      ContactMailWorker.perform_async params[:user]
      flash.now[:success] = @l.t('contact_page.thank_you')
    end

    params[:from] ||= 'empty'

    flash.now[:from] = case params[:from]
    when 'kol'
      '抱歉，我们暂未提供自助取现功能，如需要取现请通过下方的表单联系我们'
    when 'change'
      '抱歉，活动一旦创建无法自助修改，如有问题请联系我们'
    when 'recharge'
      '抱歉，我们暂未提供自助充值功能，请通过下方的表单联系我们来充值'
    else
      ''
    end

    render :layout => "website"
  end

  def withdraw_apply
    if request.get?
      @withdraw = Withdraw.new
      render :layout => "website"
    else
      params.permit!
      @withdraw = Withdraw.new(params[:withdraw])
      @withdraw.kol_id = current_kol.id
      if @withdraw.save
        flash[:notice] = "提交成功"
        if Rails.env.development?
          ContactMailWorker.new.perform @withdraw.id, true
        else
          ContactMailWorker.perform_async @withdraw.id, true
        end
        redirect_to :action => 'withdraw_apply'
      else
        return render :action => 'withdraw_apply', :layout => "website"
      end
    end
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

  def unsubscribe
    if self.request.params["token"]
      pitch_contact = PitchesContact.find_by unsubscribe_token: self.request.params["token"]
      if !pitch_contact.nil?
        email = pitch_contact.contact.email
        user_id = pitch_contact.pitch.user_id
        UnsubscribeEmail.find_or_create_by email: email, user_id: user_id
        render :layout => "website", :locals => {:action => "unsub"}
      else
        render :layout => "website"
      end
    else
      render :layout => "website"
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
