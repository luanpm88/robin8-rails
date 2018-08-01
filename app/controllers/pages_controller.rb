class PagesController < ApplicationController
  # skip_before_filter :validate_subscription
  before_action :authenticate_user!, only: [:add_ons]
  # before_action :authenticate_kol!, only: [:withdraw_apply]

  def index
    render :layout => false
  end

  def set_locale
    unless params[:locale].blank?
      someone = current_user
      someone = current_kol if current_user.nil?
      someone.update_attributes(locale: params[:locale]) unless someone.blank?
    end
    redirect_to root_path + "##{params[:current_page]}"
  end

  def home
    render 'marketing', :layout => 'brand_v2'
  end

  def kols
    # app/views/pages/kol.html.erb
    render 'kol', :layout => 'brand_v2'
  end

  def carticles
    render "carticles/show", :layout => false
  end

  def moments
    render 'marketing', :layout => 'brand_v2'
  end

  def bigv
    render 'branding', :layout => 'brand_v2'
  end

  def track_url
    @track_url = TrackUrl.find_by(:short_url => params[:id])
    @track_url.increment!(:click_count)
    TrackUrlClick.create(:track_url_id => @track_url.id, :cookie => request.cookies["_robin8_visitor"], :refer => request.referer, :user_agent => request.user_agent, :vistor_ip => request.ip)
    redirect_to @track_url.origin_url
  end

  def landing_page_brand
    render "landing_page_brand", :layout => 'landing'
  end

  def check_used_to_signed_in    #检查是否曾经登录过网站
    if UserSignInRecord.where(sign_in_token: cookies[:remember_signed_in]).present?
      render json: {success: true} and return
    end
    render nothing: true
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

  def privacy_policy
    render :layout => 'website'
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

  def screenshot_sample
    render :layout => 'website'
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

  def invite
    Rails.logger.info "------get_visitor_ip---------"
    Rails.logger.info  request.env['HTTP_X_FORWARDED_FOR']
    render :layout => false
  end

  def kol_invite
    @invite_code = InviteCode.find_by_code params[:invite_code]

    if @invite_code
      render layout: false
    else
      render text: 'not_found'
    end
  end

  #TODO redirect_to  url
  def download_invitation
    remote_ip = request.env['HTTP_X_FORWARDED_FOR'].split(",")[0]   rescue nil
    if remote_ip.present? &&  request.user_agent.present?  && params[:inviter_id].present?
      DownloadInvitation.create!(:inviter_id => params[:inviter_id], :visitor_ip => remote_ip, :visitor_agent => request.user_agent,
                                 :visitor_referer => request.referer, :visitor_cookies => cookies[:_robin8_visitor])
    end
    redirect_to params[:redirect_url] || 'http://a.app.qq.com/o/simple.jsp?pkgname=com.robin8.rb'
  end

  def kol_publish_campaign_help
    render :layout => false
  end

  def blockchain_intro
    render :layout => "mobile"
  end

end
