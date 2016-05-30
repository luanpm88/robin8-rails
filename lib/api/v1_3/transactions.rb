module API
  module V1_3
    class Transactions < Grape::API
      resources :transactions do
        before do
          authenticate!
        end

        #流水详细
        params do
          optional :page, type: Integer
        end
        get '/' do
          present :error, 0
          transactions = current_kol.transactions.page(params[:page]).per_page(10)
          to_paginate(transactions)
          present :transactions, transactions, with: API::V1_3::Entities::TransactionEntities::Summary
        end
      end
    end
  end
end
