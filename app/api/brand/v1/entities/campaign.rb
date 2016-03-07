module Brand
  module V1
    module Entities
      class Campaign < Entities::Base

        expose :id
        expose :name
        expose :description
        expose :short_description
        expose :img_url
        expose :status
        expose :user, using: Entities::User
        expose :message
        expose :url
        expose :budget
        expose :per_budget_type
        expose :per_action_budget
        expose :deadline
        expose :start_time
        expose :avail_click do |object, opts|
          object.get_avail_click
        end
        expose :total_click do |object, opts|
          object.get_total_click
        end
        expose :fee_info do |object, opts|
          object.get_fee_info
        end
        expose :share_time do |object, opts|
          object.get_share_time
        end
        expose :take_budget
        expose :remain_budget


        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end
        
      end
    end
  end
end
