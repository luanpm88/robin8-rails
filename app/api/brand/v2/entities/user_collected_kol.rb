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

        expose :description_raw do |object|
          object.desc
        end

        expose :plateform_name_type do |object|
          object.plateform_name_type.to_s
        end

        expose :bigv_url do |object|
          object.bigV_url
        end

      end
    end
  end
end
