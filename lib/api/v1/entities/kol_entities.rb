module API
  module V1
    module Entities
      module KolEntities
        class Summary < Grape::Entity
          expose :email, :mobile_number, :name, :gender, :date_of_birthday,
                 :alipay_account, :desc
          expose :country do |kol|
            kol.app_country
          end
          expose :province do |kol|
            kol.app_province
          end
          expose :city do |kol|
            kol.app_city
          end
          expose :avatar_url do |kol|
            kol.avatar.url(200)  rescue ''
          end
          #tags label #TODO 返回tag object
          expose :tags do |kol|
            kol.tags.collect{|t| t.label }
          end
          expose :tags_name do |kol|
            kol.tags.collect{|t| t.name }
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
        end
      end
    end
  end
end
