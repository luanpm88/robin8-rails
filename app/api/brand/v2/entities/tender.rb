module Brand
  module V2
    module Entities
      class Tender < Entities::Base
        expose :id, :from_terrace, :price, :fee, :link, :title, :image_url, :description, :remark
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
