module Property
  module V1
    module Entities
      class Profile < Entities::Base
        expose :id, :mobile_number, :avatar_url

        expose :name do |obj|
          obj.safe_name
        end

        expose :city do |obj|
          obj.app_city_label
        end

        expose :influence_score
        expose :avail_amount
      end
    end
  end
end
