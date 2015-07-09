class CampaignInviteSerializer < ActiveModel::Serializer
  attributes :id, :status, :created_at, :campaign, :kol, :user

  def user
    object.campaign.user
  end

end
