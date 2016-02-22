module API
  module V1
    module Entities
      module UserEntities
        class Summary < Grape::Entity
          expose :email, :mobile_number, :name, :company, :avatar_url, :locale,
                 :first_name, :last_name
          expose :desc do |user|
            user.desc
          end
        end
      end
    end
  end
end
