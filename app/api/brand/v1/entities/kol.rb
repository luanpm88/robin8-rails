module Brand
  module V1
    module Entities
      class Kol < Entities::Base
        expose :social_accounts, using: Entities::SocialAccount
        expose :id, :avatar_url, :influence_score
        expose :name do |object|
          object.safe_name
        end
        
        expose :city do |object|
          object.app_city_label
        end
      end
    end
  end
end
