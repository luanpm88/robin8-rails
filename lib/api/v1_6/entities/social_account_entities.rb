module API
  module V1_6
    module Entities
      module SocialAccountEntities
        class Summary < Grape::Entity
          expose :provider, :uid, :username, :homepage, :avatar_url, :brief, :followers_count, :friends_count,
                 :like_count, :reposts_count, :statuses_count, :price, :second_price, :repost_price
          # expose :professions do |social_account|
          #   social_account.professions.collect{|t| {:id => t.id, :label => t.label} }
          # end
        end
      end
    end
  end
end
