module API
  module V1
    class Transactions < Grape::API
      resources :transactions do
        before do
          authenticate!
        end

        params do
          optional :page, type: Integer
        end
        get '/' do
          transactions = current_kol.transactions.page(params[:page]).per_page(10)
          present :error, 0
          to_paginate(transactions)
          present :transactions, transactions, with: API::V1::Entities::TransactionEntities::Summary
        end
      end
    end
  end
end
