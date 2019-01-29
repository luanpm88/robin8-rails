module Brand
  module V2
    module Entities
      class CreationSelectedKol < Entities::Base
        expose :plateform_name, :plateform_uuid, :name, :avatar_url, :desc, :remark
        expose :creation_selected_kol_id do |object, opts|
          object.id
        end
        expose :status do |object, opts|
          ::CreationSelectedKol::STATUS[object.status.to_sym]
        end
        expose :price_total do |object, opts|
          object.tenders.sum(:price)
        end
      end
    end
  end
end
