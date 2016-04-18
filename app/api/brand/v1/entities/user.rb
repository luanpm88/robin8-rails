module Brand
  module V1
    module Entities
      class User < Entities::Base
        expose :id
        expose :name
        expose :real_name
        expose :description
        expose :keywords
        expose :url
        expose :email
        expose :avatar_url
        expose :mobile_number
        expose :amount
        expose :frozen_amount
        expose :avail_amount
      end
    end
  end
end
