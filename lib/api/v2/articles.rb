module API
  module V2
    class Articles < Grape::API
      resources :article do
        #用户绑定第三方账号
        params do
        end
        get '/' do
          if
          else
            return error_403!({error: 1, detail: '该账号已经被绑定！'})
          end
        end
      end
    end
  end
end
