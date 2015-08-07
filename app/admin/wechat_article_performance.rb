ActiveAdmin.register WechatArticlePerformance do

  permit_params :period, :reached_peoples, :page_views, :read_more, :favourite, :status

  actions :all, :except => [:new]

  article_id = 0
  campaign = ""
  report_id = 0

  member_action :approve, method: :put do
    wechat_report = WechatArticlePerformance.find(params[:id])
    wechat_report.status = 'Approved'
    wechat_report.save
    flash[:notice] = "Report is successfully approved."
    redirect_to :back
  end

  member_action :reject, method: :put do
    wechat_report = WechatArticlePerformance.find(params[:id])
    wechat_report.status = 'Rejected'
    wechat_report.save
    flash[:notice] = "Report is successfully rejected."
    redirect_to :back
  end

  before_filter only: :index do
    params[:q] = {status_in: ["Claimed", "Under moderation"]} if params[:commit].blank?
  end

  filter :period
  filter :status, as: :check_boxes, collection: [["Claimed", "Claimed"], ["Under moderation", "Under moderation"], ["Approved", "Approved"], ["Rejected", "Rejected"]]
  filter :campaign_name
  filter :company_name

  index do
    selectable_column
    id_column
    column :period
    column :reached_peoples
    column :page_views
    column :read_more
    column :favourite
    column :attachments_url do |my_resource|
      report_id = my_resource.id
      Attachment.where(:imageable_id=>my_resource.id,:imageable_type=>'WechatArticlePerformance',:attachment_type=>'image').map(&:url)
    end
    column :status
    column :claim_reason do |my_resource|
      truncate(my_resource.claim_reason, omision: "...", length: 40)
    end
    column :campaign_name do |my_resource|
      article_id = Article.find(my_resource.article_id)
      campaign = Campaign.find(article_id.campaign_id)
      link_to my_resource.campaign_name,"/admin/campaigns/"<<campaign.id.to_s
    end
    column :company_name
    actions defaults: false do |put|
      link_to 'Reject', reject_admin_wechat_article_performance_path(report_id), :method => :put
    end
    actions defaults: false do |put|
      link_to 'Approve', approve_admin_wechat_article_performance_path(report_id), :method => :put
    end
  end

end