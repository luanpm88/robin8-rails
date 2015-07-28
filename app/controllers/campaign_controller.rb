class CampaignController < ApplicationController

  def index
    status = params[:status] == "declined" ? "D" : "A"
    campaigns = kol_signed_in? ? current_kol.campaigns.joins(:campaign_invites).where(:campaign_invites => {:kol_id => current_kol.id, :status => status}) : current_user.campaigns
    render json: campaigns, each_serializer: CampaignsSerializer, scope: current_kol
  end

  def show
    c = Campaign.find(params[:id])
    user = current_user
    if user.blank? or c.user_id != user.id
      return render json: {:status => 'Thanks! We appreciate your request and will contact you ASAP'}
    end
    render json: c.to_json(:include => [:kols, :campaign_invites, :articles])
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
      Attachment.create(imageable: article, url: element[:url], attachment_type: element[:attachment_type], name: element[:name], thumbnail: element[:thumbnail])
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

  def create_article_comment
    article = Article.find(params[:article_id])
    someone = current_user
    someone = current_kol if someone.nil?
    comment = ArticleComment.create(article_id: article.id, sender: someone, text: params[:text], comment_type: "comment")
    render json: comment, serializer: ArticleCommentSerializer
  end

  def create
    if current_user.blank?
      return render :json => {:status => "thanks for submitting this. we will contact you."}
    end
    category_ids = params[:iptc_categories].split ','
    kol_ids = params[:kols].map &:id

    categories = IptcCategory.where :id => category_ids
    kols = Kol.where :id => kol_ids
    c = Campaign.new
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
    kols.each do |k|
      i = CampaignInvite.new
      i.kol = k
      i.status = ''
      i.campaign = c
      i.save

      text = params[:email_pitch]
      text = text.sub('@[First Name]', k.first_name)
      text = text.sub('@[Last Name] ', k.last_name)

      KolMailer.delay.send_invite(params[:email_address], k.email, params[:email_subject], text)
    end
    render :json => c
  end

  def add_budget
    campaign = Campaign.find(params[:campaign])
    campaign.budget = campaign.budget + params[:budget].to_i
    campaign.save
    render json: {:status => :ok}
  rescue
    render json: {:status => 'Cant add budget'}
  end

  def test_email
    KolMailer.delay.send_invite(params[:email_address], params[:emails], params[:email_subject], params[:email_pitch])
    render json: {:status => :ok}
  rescue
    render json: {:status => 'Cant send test email'}
  end

end
