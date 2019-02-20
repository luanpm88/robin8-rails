module Brand
  module V2
    module Entities
      class User < Entities::Base
        expose :id, :avatar_url, :smart_name
        expose :access_token do |user|
          user.kol.get_issue_token
        end
      end
    end
  end
end
