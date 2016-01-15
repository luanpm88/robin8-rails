class CampaignInviteSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :status,
    :start_time,
    :deadline,
    :avail_click,
    :per_action_budget,
    :remain_budget,
    :share_url,
    :description,
    :message,
    :img_url,
    :url,
    :screenshot,
    :img_status,
    :reject_reason

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

  def remain_budget
    object.campaign.remain_budget
  end

  def share_url
    unless object.share_url.present?
      object.generate_uuid_and_share_url
    end
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
end
