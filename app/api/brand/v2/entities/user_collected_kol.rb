module Brand
  module V2
    module Entities
      class UserCollectedKol < Entities::Base
        expose :id, :user_id, :kol_id, :from_by, :plateform_name, :avatar_url, :desc, :remark

        expose :profile_id do |object|
          object.plateform_uuid
        end

        expose :profile_name do |object|
          object.name
        end

      end
    end
  end
end
