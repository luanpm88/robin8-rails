module API
  module V1_4
    module Entities
      module CampaignInviteEntities
        class JoinKolsEntity < Grape::Entity
          expose :avatar_url do |invite|
            invite.kol.avatar_url
          end
          expose :kol_name do |invite|
            invite.kol.safe_name
          end

          expose :avail_click do |invite|
            invite.get_avail_click
          end

          expose :total_click do |invite|
            invite.get_total_click
          end
        end
      end
    end
  end
end