module API
  module V1
    module Entities
      module KolEntities
        class Summary < Grape::Entity
          expose :email, :mobile_number, :first_name, :last_name, :gender, :date_of_birthday,
                 :avatar_url, :country, :province, :city, :alipay_account
          expose :desc do |kol|
            ''
          end
          expose :tags do |kol|
            []
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
