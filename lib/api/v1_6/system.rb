module API
  module V1_6
    class System < Grape::API
      resources :system do
        get 'account_notice' do
          present :error, 0
          present :notices, Transaction::account_questions
        end
      end
    end
  end
end
