class CampaignController < ApplicationController

  def index
    return render json: current_user.campaigns.to_json({:methods => [:get_avail_click, :get_total_click, :get_fee_info, :get_share_time, :get_campaign_action_urls]})
  end

  def show
    c = Campaign.find(params[:id])
    user = current_user
    if (user.blank? or c.user_id != user.id)  and cookies[:admin] != "true"
      return render json: {:status => 'Thanks! We appreciate your request and will contact you ASAP'}
    end
    render json: c.to_json({:methods => [:get_avail_click, :get_total_click,  :take_budget, :remain_budget, :post_count, :get_campaign_action_urls], :include => [:valid_invites]})
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

    unless current_user.avail_amount.to_f >= params[:budget].to_f
      render :json => {:status => 'no enough amount!'} and return
    end

    campaign = Campaign.new(params.require(:campaign).permit(:name, :url, :description, :budget, :per_action_budget, :per_budget_type, :message, :img_url))
    if action_urls = params[:action_url_list]
      action_urls.each do |action_url|
        campaign.campaign_action_urls.new(action_url: action_url)
      end
    end

    campaign.user = current_user
    campaign.status = "unexecute"
    campaign.deadline = params[:campaign][:deadline].to_time
    campaign.start_time = params[:campaign][:start_time].to_time
    campaign.save!

    render :json => {:status => :ok }
  end

  def update
    # create
    campaign = Campaign.find params[:id]
    origin_budget = campaign.budget

    campaign_params = params.require(:campaign).permit(:name, :url, :description, :budget, :per_action_budget, :per_budget_type, :message, :img_url)

    unless (current_user.avail_amount.to_f + origin_budget.to_f) >= params[:budget].to_f
      render :json => {:status => 'no enough amount!'} and return
    end

    campaign.deadline = params[:campaign][:deadline].to_time
    campaign.start_time = params[:campaign][:start_time].to_time
    ActiveRecord::Base.transaction do
      campaign.update_attributes! campaign_params
      campaign.reset_campaign origin_budget, params[:budget], params[:per_action_budget]
    end

    update_campaign_action_urls campaign

    render json: {:status => :ok}
  rescue
    render json: {:status => 'something was wrong'}
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

  def day_stats
    campaign = Campaign.find params[:id]
    return render :json => {:result => 'error', :msg => 'campaign not found'}     if !campaign
    return render :json => {:result => 'error', :msg => 'campaign not start'}     if campaign.status == 'unexecue'
    stats = campaign.get_stats
    render :json => stats
  end

  def kol_list
    campaign = Campaign.find params[:id]
    return render :json => {:result => 'error', :msg => 'campaign not found'}     if !campaign
    return render :json => {:result => 'error', :msg => 'campaign not start'}     if campaign.status == 'unexecue'
    render :json => campaign.valid_invites.to_json({:methods => [:get_avail_click, :get_total_click], :include => :kol })
  end

  def test_email
    KolMailer.delay.send_invite(params[:email_address], params[:emails], params[:email_subject], params[:email_pitch])
    render json: {:status => :ok}
  rescue
    render json: {:status => 'Cant send test email'}
  end

  private
  def update_campaign_action_urls campaign
    return unless campaign.is_cpa_type?
    campaign_action_urls = params[:action_url_list].uniq

    old_action_urls = {}
    campaign.campaign_action_urls.each do |campaign_action_url|
      old_action_urls[campaign_action_url.action_url] = campaign_action_url
    end

    campaign_action_urls.each do |action_url|
      next if old_action_urls.keys.include?(action_url)
      campaign.campaign_action_urls.create(action_url: action_url)
    end

    (old_action_urls.keys - campaign_action_urls).each do |action_url|
      old_action_urls[action_url].delete
    end
  end
end
