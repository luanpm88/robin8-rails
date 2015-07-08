class CampaignController < ApplicationController

  def index
    status = params[:status] == "declined" ? "D" : "A"
    campaigns = kol_signed_in? ? current_kol.campaigns.joins(:campaign_invites).where(:campaign_invites => {:kol_id => current_kol.id, :status => status}) : current_user.campaigns
    render json: campaigns, each_serializer: CampaignsSerializer
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
    article = campaign.articles.where(kol_id: current_kol.id).first
    article.text = params[:text]
    article.save
    render json: article, serializer: ArticleSerializer
  end

  def article_comments
    article = Article.find(params[:id])
    render json: article.article_comments.order(created_at: :desc), each_serializer: ArticleCommentSerializer
  end

  def create_article_comment
    article = Article.find(params[:id])
    someone = current_user
    someone = current_kol if someone.nil?
    comment = ArticleComment.create(article_id: article.id, sender: someone, text: params[:text], comment_type: "comment")
    render json: comment, serializer: ArticleCommentSerializer
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
      KolMailer.campaign_invite(k, current_user, c).deliver
    end
    render :json => c
  end

end

