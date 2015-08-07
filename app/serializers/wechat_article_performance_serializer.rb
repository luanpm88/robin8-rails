class WechatArticlePerformanceSerializer < ActiveModel::Serializer
  attributes :id, :period, :reached_peoples, :page_views, :read_more, :favourite, :status, :article_id, :attachments, :claim_reason, :campaign_name, :company_name
end
