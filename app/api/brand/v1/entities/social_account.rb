module Brand
  module V1
    module Entities
      class SocialAccount < Entities::Base
        expose :id, :username, :avatar_url, :kol_id
        expose :provider_text
        expose :sale_price
        expose :tags, using: Entities::Tag
      end
    end
  end
end
