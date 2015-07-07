class CampaignController < ApplicationController

  def index
    campaigns = kol_signed_in? ? current_kol.campaigns : current_user.campaigns
    render json: campaigns, each_serializer: CampaignsSerializer
  end

  def create
    if current_user.blank?
      return render :json => {:status => "thanks for submitting this. we will contact you."}
    end
    category_ids = params[:categories].split ','
    kol_ids = params[:kols]
    categories = IptcCategory.where :id => category_ids
    kols = Kol.where :id => kol_ids
    c = Campaign.new
    c.user = current_user
    c.name = params[:name]
    c.description = params[:description]
    c.budget = params[:budget]
    c.release_id = params[:release]
    c.deadline = Date.parse params[:deadline]
    c.iptc_categories = categories
    c.save!
    kols.each do |k|
      i = CampaignInvite.new
      i.kol = k
      i.status = ''
      i.campaign = c
      i.save
    end
    render :json => c
  end

end

