module Brand
  module V2
    module Entities
      class Kol < Entities::Base
        expose :profile, using: Entities::CreationSelectedKol do |object, opts|
          object
        end
        expose :tenders, using: Entities::Tender do |object, opts|
          object.tenders
        end
      end

      class KolInfo < Entities::Base
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
