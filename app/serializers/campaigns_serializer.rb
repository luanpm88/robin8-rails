class CampaignsSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :img_url, :per_budget_type, :per_action_budget, :start_time, :deadline, :remain_budget, :message, :url, :has_img, :campaign_action_urls

  def img_url
    object.img_url.present? ? object.campaign.img_url : ActionController::Base.helpers.asset_path('campaign_default_img.png')
  end

  def has_img
    object.img_url.present? ? true : false
  end
  def campaign_action_urls
    return object.campaign_action_urls
  end
end
