class KolsController < ApplicationController

  def get_current_kol
    render json: current_kol, :methods => [:identities, :stats]
  end

  def create
    if request.post?
      @kol = Kol.new(kol_params)
      categories = params[:interests]
      categories = '' if categories == nil
      categories = categories.strip.split(',').map {|s| s.strip}.uniq
      @categories = IptcCategory.where :id => categories
      if @kol.valid?
        @kol.iptc_categories = @categories
        @kol.save
        sign_in @kol
        return redirect_to :root
      else
        flash.now[:errors] = @kol.errors.full_messages
        render :new, :layout => "website"
      end
    else
      @kol = Kol.new
      render :new, :layout => "website"
    end
  end

  def update_monetize
    @kol = current_kol


    #@kol.update(params)

    if @kol.update(monetize_params)
      render json: @kol, status: :ok
    else
      render :json => {error: "Something went wrong!"}, status: 422
    end
  end

  def suggest_categories
    filter = params[:f]
    filter = "" if filter == nil
    categories = IptcCategory.starts_with(filter).limit(10).map { |c| {:id => c.id, :text => c.label} }
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
    labels = ""
    unless params[:categories_id].blank?
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

  private

  def kol_params
    params.require(:kol).permit(:first_name,:last_name,:email,:password,:location,:is_public,:bank_account,:interests, :mobile_number)
  end

  def monetize_params
    params.permit(:avatar_url, :monetize_interested_all, :monetize_interested_post, :monetize_interested_create, :monetize_interested_share, :monetize_interested_review, :monetize_interested_speech, :monetize_interested_event, :monetize_interested_focus, :monetize_interested_party, :monetize_interested_endorsements, :monetize_post, :monetize_post_weibo, :monetize_post_personal, :monetize_post_public1st, :monetize_post_public2nd, :monetize_create, :monetize_create_weibo, :monetize_create_personal, :monetize_create_public1st, :monetize_create_public2nd, :monetize_share, :monetize_share_weibo, :monetize_share_personal, :monetize_share_public1st, :monetize_share_public2nd, :monetize_review, :monetize_review_weibo, :monetize_review_personal, :monetize_review_public1st, :monetize_review_public2nd, :monetize_speech, :monetize_speech_weibo, :monetize_speech_personal, :monetize_speech_public1st, :monetize_speech_public2nd, :monetize_event, :monetize_focus, :monetize_party, :monetize_endorsements)
  end

end


