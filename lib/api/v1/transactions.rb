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

        get 'recent_income' do
          recent_income = current_kol.recent_income
          present :error, 0
          present :stats, recent_income
        end

        #流水详细
        params do
          optional :page, type: Integer
        end
        get 'detail' do
          present :error, 0
          transactions = current_kol.transaction.created_desc.page(params[:page]).per_page(10)
          to_paginate(transactions)
          present :transactions, transactions, with: API::V1::Entities::TransactionEntities::Summary
        end
      end
    end
  end
end
