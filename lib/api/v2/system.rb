module API
  module V2
    class System < Grape::API
      resources :system do
        get 'account_notice' do
          present :error, 0
          present :notices, Transaction::AccountNotices
        end
      end
    end
  end
end
