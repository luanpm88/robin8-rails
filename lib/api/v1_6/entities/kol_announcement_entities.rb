module API
  module V1_6
    module Entities
      module KolAnnouncementEntities
        class Summary < Grape::Entity
          expose :category, :title
          expose :content do |kol_announcement|
            if  kol_announcement.category == 'kol'
              kol_announcement.kol_id
            else
              kol_announcement.link
            end
          end
          expose :cover_url do |kol_announcement|
            kol_announcement.cover.url
          end
        end
      end
    end
  end
end
