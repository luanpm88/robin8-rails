module Brand
  module V1
    module Entities
      class CampaignInvite < Entities::Base
        expose :id, :get_avail_click, :get_total_click, :screenshot, :img_status
        expose :kol, using: Entities::Kol
        expose :campaign, using: Entities::Campaign
        expose :img_url, using: Entities::CampaignApply

        expose :campaign_apply_status do |object, opts|
          object.campaign_apply.status
        end

        expose :agree_reason do |object, opts|
          object.campaign_apply.agree_reason
        end
      end
    end
  end
end
