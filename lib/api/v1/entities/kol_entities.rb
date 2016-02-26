module API
  module V1
    module Entities
      module KolEntities
        class Summary < Grape::Entity
          expose :email, :mobile_number, :gender, :date_of_birthday,
                 :alipay_account, :desc
          expose :name do  |kol|
            kol.name || kol.mobile_number
          end
          expose :country do |kol|
            kol.app_country
          end
          # expose :province do |kol|
          #   kol.app_province
          # end
          # expose :city do |kol|
          #   kol.app_city
          # end
          expose :app_city
          expose :app_city_label
          expose :avatar_url do |kol|
            kol.avatar.url(200)  rescue ''
          end
          expose :tags do |kol|
            kol.tags.collect{|t| {:name => t.name, :label => t.label} }
          end
          expose :issue_token do |kol|
            kol.get_issue_token
          end

        end

        class Account < Grape::Entity
          expose :amount do |kol|
            kol.amount.round(2)  rescue 0
          end
          expose :frozen_amount do |kol|
            kol.frozen_amount.round(2)  rescue 0
          end
          expose :avail_amount do |kol|
            (kol.amount - kol.frozen_amount).round(2)  rescue 0
          end
          expose :total_income
          expose :total_withdraw
          expose :today_income
        end

        class Primary < Grape::Entity
          expose :today_income
          expose :unread_count do |kol|
            kol.unread_messages.count
          end
          expose :verifying_count do |kol|
            kol.campaign_invites.verifying.count
          end
          expose :settled_count do |kol|
            kol.campaign_invites.settled.count
          end
        end

        class MessageStat < Grape::Entity
          expose :unread_message_count do |kol|
            kol.unread_messages.count
          end
          expose :new_income do |kol|
            kol.new_income
          end
        end
      end
    end
  end
end
