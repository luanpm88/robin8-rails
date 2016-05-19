module API
  module V1_3
    module Entities
      module WeixinReportEntities
        class Primary  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :email do |report|
            report['email']
          end
          expose :nick_name do |report|
            report['nick_name']
          end
          expose :logo_url do |report|
            report['logo_url']
          end
          expose :user_name do |report|
            report['user_name']
          end
          expose :total_followers_count do |report|
            report['total_followers_count']
          end
          expose :new_followers_count do |report|
            report['new_followers_count']
          end
          expose :cancel_followers_count do |report|
            report['cancel_followers_count']
          end
          expose :send_message_user_count do |report|
            report['send_message_user_count']
          end
          expose :send_message_count do |report|
            report['send_message_count']
          end
          expose :target_user_count do |report|
            report['target_user_count']
          end
          expose :read_user_count do |report|
            report['read_user_count']
          end
          # with_options(format_with: :iso_timestamp) do
          #   expose :created_at
          # end
        end

        class Message  < Grape::Entity
          expose :report_time do |report|
            report['report_time']
          end
          expose :send_message_user_count do |report|
            report['send_message_user_count']
          end
          expose :send_message_count do |report|
            report['send_message_count']
          end
          expose :per_send_message_count do |report|
            report['per_send_message_count']
          end
        end

        class Article  < Grape::Entity
          expose :article_id	 do |report|
            report['article_id']
          end
          expose :title do |report|
            report['title']
          end
          expose :publish_date do |report|
            report['publish_date']
          end
          expose :target_user_count do |report|
            report['target_user_count']
          end
          expose :read_user_count do |report|
            report['read_user_count']
          end
          expose :share_user_count do |report|
            report['share_user_count']
          end
        end

        class UserAnalysises  < Grape::Entity
          expose :report_time do |report|
            report['report_time']
          end
          expose :new_followers_count do |report|
            report['new_followers_count']
          end
          expose :cancel_followers_count do |report|
            report['cancel_followers_count']
          end
          expose :growth_followers_count do |report|
            report['growth_followers_count']
          end
          expose :total_followers_count do |report|
            report['total_followers_count']
          end
        end
      end
    end
  end
end
