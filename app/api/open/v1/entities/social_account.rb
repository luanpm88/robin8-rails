module Open
  module V1
    module Entities
      module SocialAccount
        class Summary < Grape::Entity
          expose :provider, :uid, :username, :homepage, :avatar_url, :brief, :followers_count, :friends_count,
                 :like_count, :reposts_count, :statuses_count, :price
          expose :provider_name do |social_account|
            ::SocialAccount::Providers[social_account.provider]
          end
        end
      end
    end
  end
end
