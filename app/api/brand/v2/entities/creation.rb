module Brand
  module V2
    module Entities
      class Creation < Entities::Base
        expose :name
        expose :description
        expose :trademark_name do |object, opts|
          (Trademark.find_by_id(object.trademark_id)).try(:name)
        end
        
      end
    end
  end
end
