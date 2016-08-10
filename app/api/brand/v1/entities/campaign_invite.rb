module Brand
  module V1
    module Entities
      class CampaignInvite < Entities::Base
        expose :id, :get_avail_click, :get_total_click, :screenshot, :img_status,
               :social_account_id, :kol_score, :brand_opinion
        expose :kol, using: Entities::Kol
        expose :campaign, using: Entities::Campaign
      end
    end
  end
end
