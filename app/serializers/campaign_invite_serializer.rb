class CampaignInviteSerializer < ActiveModel::Serializer
  attributes :id, :status, :sent_at, :campaign, :kol
end
