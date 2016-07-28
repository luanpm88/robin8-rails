module API
  module V1_6
    module Entities
      module KolAnnouncementEntities
        class Summary < Grape::Entity
          expose :category, :link, :kol_id
          expose :cover_url do |kol_announcement|
            kol_announcement.cover.url
          end
        end
      end
    end
  end
end
