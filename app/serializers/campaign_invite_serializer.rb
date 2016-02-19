class CampaignInviteSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :status,
    :start_time,
    :deadline,
    :avail_click,
    :per_action_budget,
    :per_budget_type,
    :remain_budget,
    :share_url,
    :description,
    :message,
    :img_url,
    :url,
    :screenshot,
    :img_status,
    :reject_reason,
    :has_img,
    :approved_at

  def name
    object.campaign.name
  end

  def start_time
    object.campaign.start_time
  end

  def deadline
    object.campaign.deadline
  end

  def avail_click
    object.get_avail_click
  end

  def per_action_budget
    object.campaign.per_action_budget.round 2
  end

  def per_budget_type
    object.campaign.per_budget_type
  end

  def remain_budget
    object.campaign.remain_budget
  end

  def share_url
    object.share_url
  end

  def description
    object.campaign.description
  end

  def message
    object.campaign.message
  end

  def url
    object.campaign.url
  end

  def img_url
    object.campaign.img_url.present? ? object.campaign.img_url : ActionController::Base.helpers.asset_path('campaign_default_img.png')

  end

  def has_img
    object.campaign.img_url.present? ? true : false
  end
end
