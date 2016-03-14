module API
  module V2
    class Notify < Grape::API
      resources :notify do
        get 'reset_elastic_index' do
          if params[:private_key] == 'robin8&influences'
            Articles::Store.reset_all_list
            present :error, 0
          else
            present :error, 1
            present :detail, 'private_key 错误'
          end
        end
      end
    end
  end
end
