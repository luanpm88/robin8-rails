module API
  module V1_3
    module Entities
      module WeiboReportEntities
        class Primary  < Grape::Entity
          expose :incremental_follower_number do |report|
            report['incremental_follower_number']
          end
          expose :decremental_follower_number do |report|
            report['decremental_follower_number']
          end
          expose :verified_follower_ratio do |report|
            report['verified_follower_ratio']
          end
          expose :unverified_follower_ratio	 do |report|
            report['unverified_follower_ratio']
          end
          expose :friend_number do |report|
            report['friend_number']
          end
          expose :follower_number do |report|
            report['follower_number']
          end
          expose :bilateral_number do |report|
            report['bilateral_number']
          end
          expose :statuses_number do |report|
            report['statuses_number']
          end
        end

        class Follower  < Grape::Entity
          expose :r_date do |report|
            report['r_date']
          end
          expose :number do |report|
            report['number']
          end
          expose :users do |report|
            report['users'] || []
          end
        end

        class Bilateral  < Grape::Entity
          expose :follower_number do |report|
            report['follower_number']
          end
          expose :bilateral_number do |report|
            report['bilateral_number']
          end
          expose :friend_number do |report|
            report['friend_number']
          end
        end


        class FollowerVerified  < Grape::Entity
          expose :general_number do |report|
            report['general_number']
          end
          expose :verified_number do |report|
            report['verified_number']
          end
          expose :expert_number do |report|
            report['expert_number']
          end
          expose :general_ratio do |report|
            report['general_ratio'].round(2)  rescue 0
          end
          expose :verified_ratio do |report|
            report['verified_ratio'].round(2)  rescue 0
          end
          expose :expert_ratio do |report|
            report['expert_ratio'].round(2)  rescue 0
          end
        end

        class FriendVerified  < Grape::Entity
          expose :r_date do |report|
            report['r_date']
          end
          expose :total_number do |report|
            report['total_number']
          end
          expose :verified_number do |report|
            report['verified_number']
          end
          expose :unverified_number do |report|
            report['unverified_number']
          end
        end

        class Gender  < Grape::Entity
          expose :male_number do |report|
            report['male_number']
          end
          expose :female_number do |report|
            report['female_number']
          end
          expose :male_ratio do |report|
            report['male_ratio']
          end
          expose :female_ratio do |report|
            report['female_ratio']
          end
        end

        class Region  < Grape::Entity
          expose :name do |report|
            report['name']
          end
          expose :code do |report|
            report['code']
          end
          expose :location do |report|
            report['location']
          end
          expose :number do |report|
            report['number']
          end
          expose :ratio do |report|
            report['ratio'].round(2)  rescue 0
          end
        end

        class Status  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 }
          expose :r_id do |report|
            report['r_id']
          end
          with_options(format_with: :iso_timestamp) do
            expose :publised_at do |report|
              report['publised_at']
            end
          end
          expose :text do |report|
            report['text']
          end
          expose :isLongText do |report|
            report['isLongText']
          end
          expose :reposts_count do |report|
            report['reposts_count']
          end
          expose :comments_count do |report|
            report['comments_count']
          end
          expose :attitudes_count do |report|
            report['attitudes_count']
          end
          expose :user do
            expose :name do  |report|
              report['user']['name']
            end
            expose :profile_image_url do  |report|
              report['user']['profile_image_url']
            end
          end
        end
      end
    end
  end
end
