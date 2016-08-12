module API
  module V1_6
    module Entities
      module KolShowEntities
        class Summary < Grape::Entity
          expose :title, :desc, :link, :provider, :cover_url
        end
      end
    end
  end
end
