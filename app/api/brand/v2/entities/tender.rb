module Brand
  module V2
    module Entities
      class Tender < Entities::Base
        expose :id
        expose :from_terrace
        expose :price
        expose :fee 
        expose :link
        expose :title
        expose :image_url
        expose :description
        expose :remark
        expose :status do |object, opts|
          ::Tender::STATUS[object.status.to_sym]
        end
        expose :kols_count do |object, opts|
          object.sub_tenders.count
        end
      end
    end
  end
end
