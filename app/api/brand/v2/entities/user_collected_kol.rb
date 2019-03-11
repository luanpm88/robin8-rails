module Brand
  module V2
    module Entities
      class UserCollectedKol < Entities::Base
        expose :id, :user_id, :kol_id, :from_by, :plateform_name, :plateform_uuid, :name, :avatar_url, :desc, :remark
      end
    end
  end
end
