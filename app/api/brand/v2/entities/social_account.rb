module Brand
  module V2
    module Entities
      class SocialAccount < Entities::Base
        expose :id, :username, :avatar_url, :kol_id
        expose :provider_text
        expose :sale_price
        expose :tags, using: Entities::Tag
      end

      class SocialAccountDetail < Entities::Base
        expose :id, :username, :avatar_url, :provider, :provider_text, :brief, :homepage, :kol_id, :gender, :city, :province
        expose :like_count, :followers_count, :friends_count, :reposts_count, :statuses_count
        expose :sale_price
        expose :tags, using: Entities::Tag
      end
    end
  end
end
