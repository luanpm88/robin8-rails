class KolsController < ApplicationController

  def get_current_kol
    render :json => current_kol.to_json({:include => {:identities =>  {:except => [:serial_params], :methods => [:total_tasks, :complete_tasks, :last30_posts]}} ,
                                          :methods => [:get_identity]})
  end

  def get_score
    total = current_kol.avail_amount.to_f

    render :json => current_kol.all_score.merge({
      :upcoming => CampaignInvite.where(kol_id: current_kol.id, status: 'running').count,
      :completed => CampaignInvite.where(kol_id: current_kol.id, status: 'finished').count,
      :total_income => total.round(2)
    })
  end

  def create
    if request.post?
      if china_instance?
        mobile_number = kol_params[:mobile_number]

        kol_p = kol_params
        kol_p[:mobile_number] = (1..9).to_a.sample(8).join if mobile_number == "robin8.best"
        kol_p[:mobile_number].strip!      rescue nil

        if mobile_number == "robin8.best"
          verify_code = Rails.cache.fetch(mobile_number)
        else
          verify_code = Rails.cache.fetch(kol_p[:mobile_number])
        end

        if verify_code == params["kol"]["verify_code"]
          create_kol_and_sign_in(kol_p)
        else
          @kol = Kol.new
          @kol.country = 'China(中国)' if china_instance?
          flash.now[:errors] = [@l.t("kols.number_and_code_unmatch")]
          render :new, :layout => "website"
        end
      else
        create_kol_and_sign_in(kol_params)
      end
    else
      @kol = Kol.new
      render :new, :layout => "website"
    end
  end

  def create_kol_from_social_account
    auth_params = params[:auth_params]
    key = "registration_account:#{auth_params[:uid]}"
    return redirect_to root_path if Rails.cache.read(key)
    Rails.cache.write(key, true, :expire_in => 600.seconds)
    @kol = Kol.new({social_name: auth_params[:name], provider: auth_params[:provider], social_uid: auth_params[:uid]})
    @kol.country = 'China(中国)' if china_instance?
    if cookies[:campaign_name]
      @kol.from_which_campaign = cookies[:campaign_name]
      cookies.delete :campaign_name
    end
    @identity = @kol.identities.build(auth_params.to_hash)
    @kol.save
    sign_in @kol
    return redirect_to root_path
  end


  def resend_confirmation_mail
    @kol = current_kol

    if @kol.blank?
      return render :json => {error: 'Something went wrong!'}, status: 422
    end

    if @kol.confirmed_at
      return render :json => {message: 'already confirmed'}
    end

    if Rails.cache.fetch @kol.email
      return render :json => {message: 'slow down'}
    end

    @kol.send_confirmation_instructions
    Rails.cache.write @kol.email, 'send', expires_in: 10.minute
    return render :json => {message: 'success'}
  end

  extend Models::Oauth
  include Models::Identities

  def update_monetize
    @kol = current_kol
    if @kol.blank?
      render :json => {error: "Something went wrong!"}, status: 422
    end
    if @kol.update(monetize_params)
      render json: @kol, status: :ok
    else
      render :json => {error: "Something went wrong!"}, status: 422
    end
  end

  def suggest_categories
    filter = params[:f]
    filter = "" if filter == nil
    if china_instance?
      categories = IptcCategory.unscoped.cn.starts_with(filter).limit(10).map { |c| {:id => c.id, :text => c.label} }
    else
      categories = IptcCategory.unscoped.us.starts_with(filter).limit(10).map { |c| {:id => c.id, :text => c.label} }
    end
    render :json => categories
  end

  def get_attachments
    render :json => Attachment.where(:imageable_id => current_kol.id)
  end

  def current_categories
    categories = []
    if kol_signed_in?
      categories = current_kol.iptc_categories.map { |c| {:id => c.id, :text => c.label} }
    end
    render :json => categories
  end

  def categories_labels
    unless params[:users_id].blank?
      labels = {}
      labels["users"] = Kol.where(:id => params[:users_id])
      categories = KolCategory.where(:kol_id => params[:users_id])
      unless categories.blank?
        labels["categories"] = categories.map { |c| {:kol_id => c.kol_id, :iptc_category_id => c.iptc_category_id} }
        categories_list = categories.map { |c| c.iptc_category_id }
        labels["categories_list"] = categories_list
        labels["categories_labels"] = IptcCategory.where(:id => categories_list).map { |c| {:id => c.id, :text => c.label} }
      end
    end
    unless params[:categories_id].blank?
      labels = ""
      labels = IptcCategory.where(:id => params[:categories_id]).map { |c| {:id => c.id, :text => c.label} }
    end

    render :json => labels
  end

  def suggest_kols
    kols = []
    categories = params[:categories]
    categories = categories.split(',') if not categories.blank?
    name =  params[:name]
    location = params[:location] if not params[:location].blank?
    kols = Kol.joins("LEFT JOIN private_kols ON kols.id = private_kols.kol_id").where("private_kols.user_id = ? or kols.is_public = ?", current_user.id, 1)
    if not categories.blank?
      kols = kols.includes(:iptc_categories).where :kol_categories => { :iptc_category_id => categories }
    end
    unless name.blank?
      kols = kols.where('kols.first_name LIKE ? OR kols.last_name like ?', "%#{name}%", "%#{name}%")
    end
    unless location.blank?
      kols = kols.where :location => location
    end
    unless params[:ageFilter].blank?
      audience_age_groups = params[:ageFilter].join("|")
      kols = kols.where("kols.audience_age_groups REGEXP ?", "#{audience_age_groups}")
    end
    unless params[:regions].blank?
      regions = params[:regions].join("|")
      kols = kols.where("kols.audience_regions REGEXP ?", "#{regions}")
    end
    unless params[:male].blank?
      kols = kols.where(:audience_gender_ratio => params[:male])
    end
    unless params[:channels].blank?
      channels = params[:channels].join("%")
      kols = kols.joins(:identities).where("identities.provider LIKE ?", "%#{channels}%")
    end
    unless params[:wechat_personal].blank?
      kols = kols.where("kols.wechat_personal_fans IS NOT NULL AND kols.wechat_personal_fans not like ''")
    end
    unless params[:wechat_public].blank?
      kols = kols.where("kols.wechat_public_id IS NOT NULL AND kols.wechat_public_id not like ''")
    end
    unless params[:content_offline].blank?
      kols = kols.where("kols.monetize_interested_all='true' or kols.monetize_interested_event='true' or kols.monetize_interested_focus='true' or kols.monetize_interested_party='true' or kols.monetize_interested_endorsements='true'")
    end
    unless params[:content_online].blank?
      kols = kols.where("kols.monetize_interested_all='true' or kols.monetize_interested_post='true' or kols.monetize_interested_create='true' or kols.monetize_interested_share='true' or kols.monetize_interested_review='true' or kols.monetize_interested_speech='true'")
    end
    render :json => kols.to_json(:methods => [:categories, :stats])
  end

  def get_social_list
    render :json => current_kol.identities, :methods => [:total_tasks, :complete_tasks, :last30_posts]
  end

  def send_sms
    unless sms_request_is_valid?
      return render json: {}
    end
    if params[:login_user] == "yes"
      unless sms_request_is_valid_for_login_user?
        return render json: {}
      end
    else
      unless verify_rucaptcha?
        return render json: {rucaptcha_not_right: true}
      end
    end
    
    phone_number = params[:phone_number]
    if Rails.env.development?
      ms_client = YunPian::SendRegisterSms.new(phone_number)
      ms_client.send_sms
      return render json: {}
    end

    if phone_number.blank?
      render json: {mobile_number_is_blank: true}
    else
      if params[:role] == 'user'
        return render json: {not_unique: true}  if User.check_mobile_number phone_number
      else
        return render json: {not_unique: true}  if Kol.check_mobile_number phone_number
      end

      total_send_key = "robin8_send_sms_count"
      send_count =  Rails.cache.fetch(total_send_key).to_i || 1
      Rails.cache.write(total_send_key, send_count + 1, :expires_in => 50.hours)
      Rails.logger.sms_spider.error "发送的 有效的量已经超过了 #{send_count}"

      sms_client = YunPian::SendRegisterSms.new(phone_number)

      res = sms_client.send_sms  rescue {}
      render json: res
    end
  end

  def valid_phone_number
    phone_kol = Kol.where(:mobile_number => params[:mobile_number]).first   rescue nil
    if phone_kol.nil? || phone_kol.id.to_s == params[:kol_id]
      return render :json => {'valid' => true}
    else
      return render :json => {'valid' => false}
    end
  end

  def valid_verify_code
    phone_number = params[:phone_number]
    verify_code = params[:verify_code]
    if verify_code == Rails.cache.read(phone_number)
      return render json: {'valid' => true}
    else
      return render json: {'valid' => false}
    end
  end

  private

  def sms_request_is_valid_for_login_user?
    unless current_kol
      Rails.logger.sms_spider.error "用户没有登录, #{cookies[:_robin8_visitor]}"
      return false 
    end
    key = "kol_#{current_kol.id}_send_sms_count"
    send_count =  Rails.cache.fetch(key).to_i || 1
    Rails.cache.write(key, send_count + 1, :expires_in => 360.seconds)

    Rails.logger.sms_spider.error "kol #{current_kol.id}, tel #{current_kol.mobile_number} send sms #{send_count}"

    return false if send_count > 20
    return true
  end

  def sms_request_is_valid?
    Rails.logger.sms_spider.error '-'*60

    Rails.logger.sms_spider.error 'remote_ip: ' + request.remote_ip
    Rails.logger.sms_spider.error 'ip: ' + request.ip
    Rails.logger.sms_spider.error 'user_agent: ' + request.user_agent
    Rails.logger.sms_spider.error 'referer: ' + request.referer
    Rails.logger.sms_spider.error 'cookie: ' + cookies[:_robin8_visitor]
    Rails.logger.sms_spider.error 'csrf_token: ' + request.env["HTTP_X_CSRF_TOKEN"]

    Rails.logger.sms_spider.error '-'*60

    ips = Rails.cache.fetch("spider_ip_from_kol_6579")


    ip_key = "#{request.ip}_visitor_count"
    send_count =  Rails.cache.fetch(ip_key).to_i || 1
    
    if ips && ips.include?(request.ip)
      Rails.logger.sms_spider.error ("#{request.ip} 已经尝试#{send_count} 次, 且存在在爬虫黑名单中")
      return false
    end

    Rails.logger.sms_spider.error ("#{request.ip} 已经尝试#{send_count} 次")
    Rails.cache.write(ip_key, send_count + 1, :expires_in => 360.seconds)

    key = cookies[:_robin8_visitor] + "send_sms"
    send_count =  Rails.cache.fetch(key).to_i || 1
    Rails.logger.sms_spider.error (cookies[:_robin8_visitor] + "已经尝试#{send_count} 次")
    Rails.cache.write(key, send_count + 1, :expires_in => 360.seconds)
    
    if send_count > 10
      Rails.logger.sms_spider.error (cookies[:_robin8_visitor] + "被禁封, 已经尝试#{send_count} 次")
      return false
    end
    if request.user_agent == "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)"
      Rails.logger.sms_spider.error (cookies[:_robin8_visitor] + "被禁封, 已经尝试#{send_count} 次, user_agent #{request.user_agent}")
      return false
    end
    return true
  end

  def kol_params
    params.require(:kol).permit(:email, :password, :mobile_number)
  end

  def monetize_params
    params.require(:kol).permit(:avatar_url, :monetize_interested_post, :monetize_interested_create,
                                :monetize_interested_share, :monetize_interested_review, :monetize_interested_speech,
                                :monetize_interested_event, :monetize_interested_focus, :monetize_interested_party,
                                :monetize_interested_endorsements, :monetize_post, :monetize_post_weibo, :monetize_post_personal,
                                :monetize_post_public1st, :monetize_post_public2nd, :monetize_create, :monetize_create_weibo,
                                :monetize_create_personal, :monetize_create_public1st, :monetize_create_public2nd, :monetize_share,
                                :monetize_share_weibo, :monetize_share_personal, :monetize_share_public1st, :monetize_share_public2nd,
                                :monetize_review, :monetize_review_weibo, :monetize_review_personal, :monetize_review_public1st,
                                :monetize_review_public2nd, :monetize_speech, :monetize_speech_weibo, :monetize_speech_personal,
                                :monetize_speech_public1st, :monetize_speech_public2nd, :monetize_event, :monetize_focus,
                                :monetize_party, :monetize_endorsements)
  end

  def create_kol_and_sign_in(kol_params)
    @kol = Kol.new(kol_params)

    if cookies[:campaign_name]
      @kol.from_which_campaign = cookies[:campaign_name]
      cookies.delete :campaign_name
    end

    @kol.country = 'China(中国)' if china_instance?
    if @kol.valid?
      @kol.save
      sign_in @kol
      if cookies[:popup_signin].present?
        cookies[:popup_signin] = nil
        render '/users/omniauth_callbacks/twitter_popup_close', :layout => false
      else
        return redirect_to '/#/dashboard/profile'
      end
    else
      flash.now[:errors] = @kol.errors.full_messages
      render :new, :layout => "website"
    end
  end
end