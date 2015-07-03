class CampaignInviteSerializer < ActiveModel::Serializer
  attributes :id, :status, :created_at, :campaign, :kol
end
