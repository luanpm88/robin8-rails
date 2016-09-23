module Open
  module V1
    module Entities
      module KolShow
        class Summary < Grape::Entity
          expose :title, :desc, :link, :provider, :cover_url
        end
      end
    end
  end
end
