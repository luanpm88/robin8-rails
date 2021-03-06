module API
  module V1_6
    class System < Grape::API
      resources :system do
        get 'account_notice' do
          account_questions = HelperDoc.all.order("sort_weight").page(params[:page]).per_page(40).map do |doc|
            {:question => doc.question, :answer => doc.answer}
          end
          present :error, 0
          present :notices, account_questions
        end
      end
    end
  end
end
