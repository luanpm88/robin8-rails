module Property
  module V1
    module Entities
      class Account < Entities::Base
        expose :id
        expose :mobile_number
        expose :union_token do |obj|
          obj.union_access_token.token
        end
        expose :union_token_created_at do |obj|
          obj.union_access_token.created_at
        end
        expose :union_token_expires_in do |obj|
          obj.union_access_token.expires_in
        end
        expose :show_count do |obj|
          obj.show_count
        end
      end
    end
  end
end
