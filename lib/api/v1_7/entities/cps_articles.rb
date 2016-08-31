module API
  module V1_7
    module Entities
      module CpsArticles
        class Summary < Grape::Entity
          expose :id, :title, :cover_url, :text
          expose :url do |carticle|
            "/carticles/#{carticle.id}"
          end
        end
      end
    end
  end
end
