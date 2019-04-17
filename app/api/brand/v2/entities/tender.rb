module Brand
  module V2
    module Entities
      class Tender < Entities::Base
        expose :id, :from_terrace, :fee, :link, :title, :image_url, :description, :remark
        expose :price do |object|
          object.price.to_f
        end
        expose :status do |object, opts|
          ::Tender::STATUS[object.status.to_sym]
        end
        expose :amount do |object, opts|
          object.amount.to_f
        end
        expose :brand_show_info do |object, opts|
          object.brand_show_info
        end
        expose :brand_show_info_zh do |object|
          object.brand_show_info_zh
        end
        expose :kols_count do |object, opts|
          object.kols_count
        end
      end
    end
  end
end
