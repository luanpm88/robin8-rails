module Brand
  module V2
    module Entities
      class UserInfo < Entities::Base
        expose :id
        expose :name
        expose :real_name
        expose :campany_name
        expose :description
        expose :keywords
        expose :url
        expose :email
        expose :avatar_url
        expose :mobile_number
        expose :amount
        expose :frozen_amount
        expose :avail_amount
        expose :credit_amount
        expose :credit_expired_at
        expose :recharge_min_budget do |user|
          MySettings.recharge_min_budget
        end
        expose :campaign_min_budget do |user|
          MySettings.campaign_min_budget
        end
        expose :cpc_min_budget do |user|
          MySettings.cpc_min_budget
        end
        expose :cpp_min_budget do |user|
          MySettings.cpp_min_budget
        end
        expose :cpt_one_min_budget do |user|
          MySettings.cpt_one_min_budget
        end
        expose :cpt_two_min_budget do |user|
          MySettings.cpt_two_min_budget
        end
        expose :cpt_three_min_budget do |user|
          MySettings.cpt_three_min_budget
        end
      end
    end
  end
end
