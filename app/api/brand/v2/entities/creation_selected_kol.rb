module Brand
  module V2
    module Entities
      class CreationSelectedKol < Entities::Base
        expose :plateform_name
        expose :plateform_uuid
        expose :name 
        expose :avatar_url
        expose :desc
        expose :remark
      end
    end
  end
end
