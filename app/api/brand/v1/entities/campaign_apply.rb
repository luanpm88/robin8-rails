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
      end
    end
  end
end
