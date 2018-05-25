module Brand
  module V1
    module Entities
      class Credit < Entities::Base
        expose :id, :direct, :show_time, :score, :amount
        expose :remark do |object|
          object.send("#{object._method}_remark")
        end
      end
    end
  end
end
