module API
  module V1_6
    module Entities
      module ProfessionEntities
        class Summary < Grape::Entity
          expose :kol_id, :provider, :uid, :username, :homepage, :avatar_url, :brief, :followers_count, :friends_count,
                 :like_count, :reposts_count, :statuses_count, :price, :screenshot, :second_price, :repost_price
        end
      end
    end
  end
end
