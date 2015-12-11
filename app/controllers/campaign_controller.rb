class CampaignController < ApplicationController

  def index
    if params[:status] == "declined" || params[:status] == "accepted"
      status = params[:status] == "declined" ? "D" : "A"
      campaigns = kol_signed_in? ? current_kol.campaigns.joins(:campaign_invites).where(:campaign_invites => {:kol_id => current_kol.id, :status => status}).where("campaigns.deadline > ?", Time.zone.now.beginning_of_day).order('deadline DESC') : current_user.campaigns
    elsif params[:status] == "latest"
      if kol_signed_in?
        campaigns_invited = current_kol.campaigns.joins(:campaign_invites).where(:campaign_invites => {:kol_id => current_kol.id}).where("campaigns.deadline > ?", Time.zone.now.beginning_of_day).order('deadline DESC').map { |c| c.id }
        campaigns_latest = Campaign.where("created_at > ? and deadline > ?",Date.today - 14, Time.zone.now.beginning_of_day).order('deadline DESC').map { |c| c.id }
        campaigns_latest-=campaigns_invited
        campaigns = Campaign.where(:id => campaigns_latest).where("deadline > ?", Time.zone.now.beginning_of_day).order('deadline DESC')
      else
        campaigns = current_user.campaigns
      end
    elsif params[:status] == "history"
      campaigns = kol_signed_in? ? Campaign.joins(:interested_campaigns).where("interested_campaigns.kol_id = ? and campaigns.deadline <= ?", current_kol.id, Time.zone.now.beginning_of_day) | current_kol.campaigns.joins(:campaign_invites).where("campaign_invites.kol_id = ? and campaigns.deadline <= ?", current_kol.id, Time.zone.now.beginning_of_day) : current_user.campaigns
    elsif params[:status] == "all"
      if kol_signed_in?
        categories = KolCategory.where(:kol_id => current_kol.id).map { |c| c.iptc_category_id }
        campaigns_all = CampaignCategory.where(:iptc_category_id => categories).map { |c| c.campaign_id }
        campaigns_invites = CampaignInvite.where(:kol_id => current_kol.id).map { |c| c.campaign_id }
        campaigns_all-=campaigns_invites
        campaigns = Campaign.where(:id => campaigns_all).where("deadline > ?", Time.zone.now.beginning_of_day).order('deadline DESC')
      else
        render json: current_user.campaigns.to_json({:methods => [:get_avail_click, :get_fee_info, :get_share_time]})
      end
    elsif params[:status] == "negotiating"
      campaigns = kol_signed_in? ? current_kol.campaigns.joins(:campaign_invites).where(:campaign_invites => {:kol_id => current_kol.id, :status => 'N'}).where("campaigns.deadline > ?", Time.zone.now.beginning_of_day).order('deadline DESC') : current_user.campaigns
    else
      campaigns = kol_signed_in? ? current_kol.campaigns.joins(:campaign_invites).where(:campaign_invites => {:kol_id => current_kol.id, :status => 'A'}) : current_user.campaigns
    end
    render json: campaigns, each_serializer: CampaignsSerializer, campaign_status: params[:status], scope: current_kol
  end

  def show
    c = Campaign.find(params[:id])
    user = current_user
    if user.blank? or c.user_id != user.id
      return render json: {:status => 'Thanks! We appreciate your request and will contact you ASAP'}
    end
    render json: c.to_json(:include => [:kols, :campaign_invites, :weibo, :weibo_invites, :articles, :kol_categories, :iptc_categories, :interested_campaigns])
  end

  def article
    campaign = Campaign.find(params[:id])
    if params[:article_id]
      article = campaign.articles.find(params[:article_id])
    else
      article = campaign.articles.where(kol_id: current_kol.id).first
    end
    render json: article, serializer: ArticleSerializer
  end

  def update_article
    campaign = Campaign.find(params[:id])
    if current_user.nil?
      article = campaign.articles.where(kol_id: current_kol.id).first
      article.text = params[:text]
      article.save
    else
      article = Article.find(params[:article_id])
    end
    unless params[:attachments_attributes].blank?
      params[:attachments_attributes].each do |element|
        if element[:attachment_type] == "file"
          Attachment.create(imageable: article, url: element[:url], attachment_type: element[:attachment_type], name: element[:name], thumbnail: element[:thumbnail])
        end
      end
    end
    render json: article, serializer: ArticleSerializer
  end

  def approve_article
    c = Campaign.find(params[:id])
    user = current_user
    if user.blank? or c.user_id != user.id
      return render json: {:status => 'Thanks! We appreciate your request and will contact you ASAP'}
    end
    article = c.articles.find(params[:article_id])
    code = article.approve
    render json: {:code => code}
  end

  def approve_request
    campaign = Campaign.find(params[:id])
    if current_user.nil?
      article = campaign.articles.where(kol_id: current_kol.id).first
      article.tracking_code = 'Waiting'
      article.save
    else
      article = Article.find(params[:article_id])
    end
    render json: article, serializer: ArticleSerializer
  end

  def article_comments
    article = Article.find(params[:article_id])
    render json: article.article_comments.order(created_at: :desc), each_serializer: ArticleCommentSerializer
  end

  def wechat_performance
    article = Article.find(params[:article_id])
    render json: article.wechat_article_performances.order(created_at: :desc), each_serializer: WechatArticlePerformanceSerializer
  end

  def create_article_comment
    article = Article.find(params[:article_id])
    someone = current_user
    someone = current_kol if someone.nil?
    comment = ArticleComment.create(article_id: article.id, sender: someone, text: params[:text], comment_type: "comment")
    render json: comment, serializer: ArticleCommentSerializer
  end

  def create_wechat_performance
    article = Article.find(params[:article_id])
    campaign = Campaign.find(article.campaign_id)
    user = User.find(campaign.user_id)
    wechat_perf = WechatArticlePerformance.create(article_id: article.id, reached_peoples: params[:reached_peoples],
                                                  page_views: params[:page_views], read_more: params[:read_more], favourite: params[:favourite],
                                                  status: "Under moderation", period: Date.today.to_s, campaign_name: campaign.name, company_name: user.company)
    params[:attachments_attributes].each do |element|
      if element[:attachment_type] == "image"
        Attachment.create(imageable_id: wechat_perf.id, imageable_type: "WechatArticlePerformance", url: element[:url], attachment_type: element[:attachment_type], name: element[:name], thumbnail: element[:thumbnail])
      end
    end
    render json: wechat_perf, serializer: WechatArticlePerformanceSerializer
  end

  def claim_article_wechat_performance
    wechat_report = WechatArticlePerformance.find(params[:reportId])
    wechat_report.claim_reason = params[:reason]
    wechat_report.status = 'Claimed'
    wechat_report.save
    render json: wechat_report, serializer: WechatArticlePerformanceSerializer
  end

  def negotiate_campaign
    campaign = Campaign.find(params[:id])
    campaign_invite = CampaignInvite.where(:campaign_id=>campaign.id, :kol_id=>current_kol.id).first
    campaign_invite.status = 'N'
    campaign_invite.save
    article = campaign.articles.where(kol_id: current_kol.id).first
    if article.blank?
      article = Article.new(kol_id: current_kol.id, campaign_id: params[:id], tracking_code: 'Negotiating')
      article.save
    else
      article.tracking_code = 'Negotiating'
      article.save
    end
    someone = current_user
    someone = current_kol if someone.nil?
    comment = ArticleComment.create(article_id: article.id, sender: someone, text: params[:text], comment_type: "comment")
    render json: comment, serializer: ArticleCommentSerializer
  end

  def create
    if current_user.blank?
      return render :json => {:status => 'Thanks! We appreciate your request and will contact you ASAP'}
    end
    campaign = Campaign.new(params.require(:campaign).permit(:name, :url, :description, :budget, :per_click_budget, :start_time, :deadline, :message))
    campaign.user = current_user
    campaign.status = "unexecute"

    campaign.save!
    render :json => {:status => :ok }
  end

  def update
    create
  end


  def add_budget
    campaign = Campaign.find(params[:campaign])
    campaign.budget = campaign.budget + params[:budget].to_i
    campaign.save
    render json: {:status => :ok}
  rescue
    render json: {:status => 'Cant add budget'}
  end

  def get_counter
    response = HTTParty.post(Rails.application.secrets[:pos_tagger_api][:url],
                               body: {text: params[:description]}).parsed_response

    characters_count = response["characters_count"]
    words_count = response["words_count"]
    sentences_count = response["sentences_count"]
    paragraphs_count = response["paragraphs_count"]
    nouns_count = response["nouns_count"]
    adjectives_count = response["adjectives_count"]
    adverbs_count = response["adverbs_count"]

    client = AylienTextApi::Client.new

    response = client.entities! text: params[:description]

    organizations_count = (response[:entities][:organization] || []).size
    places_count = (response[:entities][:location] || []).size
    people_count = (response[:entities][:person] || []).size

    render json: {'characters_count' => characters_count, 'words_count' => words_count, 'sentences_count' => sentences_count, 'paragraphs_count' => paragraphs_count, 'nouns_count' => nouns_count, 'adjectives_count' => adjectives_count, 'adverbs_count' => adverbs_count, 'organizations_count' => organizations_count, 'places_count' => places_count, 'people_count' => people_count}
  end

  def test_email
    KolMailer.delay.send_invite(params[:email_address], params[:emails], params[:email_subject], params[:email_pitch])
    render json: {:status => :ok}
  rescue
    render json: {:status => 'Cant send test email'}
  end

end
