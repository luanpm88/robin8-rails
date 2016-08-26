module API
  module V1_7
    module Entities
      module Carticles
        class Detail < Grape::Entity
          expose :id, :body
          expose :url do |carticle|
            "/carticles/#{carticle.id}"
          end
        end
      end
    end
  end
end