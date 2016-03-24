module API
  module V2
    class Notify < Grape::API
      resources :notify do
        get 'clean_cache' do
          if params[:private_key] == 'robin8'
            ::Articles::Store.reset_all_list
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
