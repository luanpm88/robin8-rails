class CampaignController < ApplicationController

  def index
    if params[:status] == "declined" || params[:status] == "accepted"
      status = params[:status] == "declined" ? "D" : "A"
      campaigns = kol_signed_in? ? current_kol.campaigns.joins(:campaign_invites).where(:campaign_invites => {:kol_id => current_kol.id, :status => status}) : current_user.campaigns
    end
    if params[:status] == "latest"
      campaigns = kol_signed_in? ? Campaign.where("created_at > ?",Date.today - 14).order('deadline DESC') : current_user.campaigns
    end
    if params[:status] == "history"
      campaigns = kol_signed_in? ? current_kol.campaigns.joins(:campaign_invites).where("campaign_invites.kol_id = ? and campaign_invites.status = 'A' and campaigns.deadline < ?", 3, Time.zone.now.beginning_of_day) : current_user.campaigns
    end
    if params[:status] == "all"
      campaigns = kol_signed_in? ? Campaign.where("deadline > ?", Time.zone.now.beginning_of_day).order('deadline DESC') : current_user.campaigns
    end
    if params[:status] == "negotiating"
      campaigns = kol_signed_in? ? current_kol.campaigns.joins(:campaign_invites).where(:campaign_invites => {:kol_id => current_kol.id, :status => 'N'}) : current_user.campaigns
    end
    render json: campaigns, each_serializer: CampaignsSerializer, campaign_status: params[:status], scope: current_kol
  end

  def show
    c = Campaign.find(params[:id])
    user = current_user
    if user.blank? or c.user_id != user.id
      return render json: {:status => 'Thanks! We appreciate your request and will contact you ASAP'}
    end
    render json: c.to_json(:include => [:kols, :campaign_invites, :weibo, :weibo_invites, :articles])
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
    params[:attachments_attributes].each do |element|
      if element[:attachment_type] == "file"
        Attachment.create(imageable: article, url: element[:url], attachment_type: element[:attachment_type], name: element[:name], thumbnail: element[:thumbnail])
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

  def create
    if current_user.blank?
      return render :json => {:status => 'Thanks! We appreciate your request and will contact you ASAP'}
    end
    category_ids = params[:iptc_categories].split ','
    kol_ids = params[:kols].map { |k| k[:id] }
    categories = IptcCategory.where :id => category_ids
    kols = Kol.where :id => kol_ids
    weibos = params[:weibo]
    if params[:id]
      c = Campaign.find(params[:id])
      if c.user_id != current_user.id
        return render json: {:status => 'Thanks! We appreciate your request and will contact you ASAP'}
      end
    else
      c = Campaign.new
    end
    c.user = current_user
    c.name = params[:name]
    c.description = (params[:description]).gsub( %r{</?[^>]+?>}, '' )
    c.budget = params[:budget]
    c.release_id = params[:release]
    c.deadline = Date.parse params[:deadline]
    c.iptc_categories = categories
    c.concepts = params[:concepts]
    c.summaries = params[:summaries]
    c.hashtags = params[:hashtags]
    c.save!

    #private kol
    kols.each do |k|
      i = c.campaign_invites.where(kol_id: k.id).first
      if !i
        i = CampaignInvite.new
        i.kol = k
        i.status = ''
        i.campaign = c
        i.save
        text = params[:email_pitch]
        text = text.sub('@[First Name]', k.first_name)
        text = text.sub('@[Last Name]', k.last_name)

        KolMailer.delay.send_invite(params[:email_address], k.email, params[:email_subject], text)
      end
    end

    #weibo
    weibos.each do |w|
      stored_weibo = Weibo.where(pressr_id: w[:id]).first
      if !stored_weibo
        weibo = Weibo.new
        weibo.pressr_id = w[:id]
        weibo.first_name = w[:first_name]
        weibo.last_name = w[:last_name]
        weibo.full_name = w[:full_name]
        weibo.email = w[:email]
        weibo.save
        stored_weibo = weibo
      end

      i = c.weibo_invites.where(weibo_id: stored_weibo.id).first
      if !i
        i = WeiboInvite.new
        i.weibo = stored_weibo
        i.campaign = c
        i.save
      end
    end

    render json: {:status => :ok}
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
