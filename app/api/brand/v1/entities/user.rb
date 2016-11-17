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
        expose :recharge_min_budget do |user|
          MySettings.recharge_min_budget
        end
        expose :campaign_min_budget do |user|
          MySettings.campaign_min_budget
        end
      end
    end
  end
end
