module Brand
  module V1
    module Entities
      class CampaignApply < Entities::Base
        expose :kol, using: Entities::Kol
        expose :campaign, using: Entities::Campaign
        expose :status, :agree_reason
        expose :screenshot do |object, opts|
          object.campaign_invite.screenshot
        end
        expose :weixin_friend_count
        expose :weibo_friend_count do |object, opts|
          object.kol.identities.where(provider: 'weibo').maximum("followers_count")
        end
        expose :brand_passed_count do |object, opts|
          object.campaign.brand_passed_applies.count
        end
      end
    end
  end
end
