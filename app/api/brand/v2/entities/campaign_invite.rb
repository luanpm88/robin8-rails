module Brand
  module V2
    module Entities
      class CampaignInvite < Entities::Base
        expose :id, :get_avail_click, :get_total_click, :screenshot, :img_status,
               :social_account_id, :kol_score, :brand_opinion
        #奖励
        expose :total_rewards do |object|
          object.earn_money
        end
        expose :kol, using: Entities::KolInfo
        expose :campaign, using: Entities::Campaign
      end
    end
  end
end
