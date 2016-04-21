module Brand
  module V1
    module Entities
      class CampaignApply < Entities::Base
        expose :status, :agree_reason
      end
    end
  end
end
