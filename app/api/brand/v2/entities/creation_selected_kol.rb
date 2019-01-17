module Brand
  module V2
    module Entities
      class CreationSelectedKol < Entities::Base
        expose :platefrom_name
        expose :platefrom_uuid
        expose :name 
        expose :avatar_url
        expose :desc
        expose :remark
      end
    end
  end
end
