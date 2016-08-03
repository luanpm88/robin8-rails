module Brand
  module V1
    module Entities
      class SocialAccount < Entities::Base
        expose :id, :username, :avatar_url, :kol_id
        expose :provider_text
        expose :sale_price
        expose :professions, using: Entities::Profession
      end
    end
  end
end
