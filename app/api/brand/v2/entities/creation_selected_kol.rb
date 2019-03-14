module Brand
  module V2
    module Entities
      class CreationSelectedKol < Entities::Base
        expose :plateform_name, :avatar_url, :remark, :status

        expose :creation_selected_kol_id do |object|
          object.id
        end
        expose :status_zh do |object|
          object.status_zh
        end
        expose :price_total do |object|
          object.tenders.sum(:price).to_f
        end

        expose :profile_id do |object|
          object.plateform_uuid
        end

        expose :profile_name do |object|
          object.name
        end

        expose :description_raw do |object|
          object.desc
        end
      end
    end
  end
end
