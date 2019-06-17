module API
  module V1
    module Entities
      module AnnouncementEntities
        class Summary < Grape::Entity
          expose :id, :title, :desc, :url, :detail_type
          # expose :logo_url do |anno|
          #   anno.logo.url
          # end
          expose :banner_url do |anno|
            anno.banner_url
          end
        end
      end
    end
  end
end
