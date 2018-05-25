module Brand
  module V1
    module Entities
      class Credit < Entities::Base
        expose :trade_no, :direct, :show_time, :score, :amount
        expose :remark do |object|
          object.send("#{object._method}_remark")
        end
      end
    end
  end
end
