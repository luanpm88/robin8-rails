module API
  module V2
    class Messages < Grape::API
      resources :messages do
        before do
          authenticate!
        end

        put 'read_all' do
          current_kol.read_all
          present :error, 0
        end
      end
    end
  end
end
