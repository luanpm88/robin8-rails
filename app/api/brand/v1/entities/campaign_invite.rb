module Brand
  module V1
    module Entities
      class CampaignInvite < Entities::Base
        expose :id, :get_avail_click, :get_total_click, :screenshot, :img_status
        expose :kol, using: Entities::Kol
      end
    end
  end
end