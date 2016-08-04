module API
  module V1_6
    module Entities
      module BigVEntities
        class Summary < Grape::Entity
          expose :id, :name, :job_info
          expose :tags do |big_v|
            big_v.tags.collect{|t| {:name => t.name, :label => t.label} }
          end
          expose :avatar_url do |big_v|
            big_v.get_avatar_url
          end
          expose :social_accounts, using: API::V1_6::Entities::SocialAccountEntities::Summary
        end

        class Detail < Grape::Entity
          expose :id, :name, :job_info, :desc, :app_city_label
          expose :avatar_url do |big_v|
            big_v.get_avatar_url
          end
          expose :tags do |big_v|
            big_v.tags.collect{|t| {:name => t.name, :label => t.label} }
          end
        end

        class My < Grape::Entity
          expose :id, :name, :kol_role, :max_campaign_click, :max_campaign_earn_money, :campaign_total_income, :avg_campaign_credit
          expose :avatar_url do |big_v|
            big_v.get_avatar_url
          end
          expose :tags do |big_v|
            big_v.tags.collect{|t| {:name => t.name, :label => t.label} }
          end
        end
      end
    end
  end
end
