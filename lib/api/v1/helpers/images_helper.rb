module API
  module V1
    module Helpers
      module ImagesHelper
        def get_type_obj(type, type_id)
          type.titleize.safe_constantize.find type_id
        end
      end
    end
  end
end