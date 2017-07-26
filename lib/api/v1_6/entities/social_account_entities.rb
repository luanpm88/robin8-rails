module API
  module V1_6
    module Entities
      module SocialAccountEntities
        class Summary < Grape::Entity
          expose :id, :provider, :uid, :username, :homepage, :avatar_url, :brief, :followers_count, 
                 :friends_count, :like_count, :reposts_count, :statuses_count, :price, :search_kol_id
          expose :provider_name do |social_account|
            SocialAccount::Providers[social_account.provider]
          end
        end
      end
    end
  end
end
