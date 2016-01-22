module API
  module V1
    module Entities
      module KolEntities
        class Summary < Grape::Entity
          expose :email, :mobile_number, :first_name, :last_name, :gender, :date_of_birthday
          expose :issue_token do |kol|
            kol.get_issue_token
          end
        end

        class Account < Grape::Entity
          expose :amount, :frozen_amount
          expose :avail_amount do |kol|
            kol.amount - kol.frozen_amount
          end
        end
      end
    end
  end
end
