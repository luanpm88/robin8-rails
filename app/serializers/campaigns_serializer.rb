class CampaignsSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :img_url, :per_budget_type, :per_action_budget, :start_time, :deadline, :remain_budget, :message, :url, :has_img

  def img_url
    object.img_url.present? ? object.img_url : ActionController::Base.helpers.asset_path('campaign_default_img.png')
  end

  def has_img
    object.img_url.present? ? true : false
  end
end
