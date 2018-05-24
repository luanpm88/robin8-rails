module Brand
  module V1
    class TransactionsAPI < Base
      include Grape::Kaminari
      before do
        authenticate!
      end

      resource :transactions do
        paginate per_page: 8
        get "/" do
          transactions = paginate(Kaminari.paginate_array(current_user.paid_transactions.includes(:item).order('created_at DESC')))
          present transactions
        end
      end
    end
  end
end
