module Open
  module V1
    class TransactionAPI < Base
      before do
        authenticate!
        request_limit!
      end

      resource :transactions do
        desc "get all transactions of current user"
        params do
          optional :page,   type: Integer
        end
        get "/" do
          @transactions = current_user.transactions

          @transactions = @transactions.order("created_at DESC").page(params[:page]).per_page(20)

          present :success, true
          present :avail_amount, current_user.avail_amount.to_f
          present :transactions, @transactions, with: Open::V1::Entities::Transaction::TransactionList
          present :total_count,  @transactions.count
          present :current_page, @transactions.current_page
          present :total_pages,  @transactions.total_pages
        end
      end

    end
  end
end