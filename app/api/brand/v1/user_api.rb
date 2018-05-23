module Brand
  module V1
    class UserAPI < Base
      include Grape::Kaminari

      before do
        authenticate!
      end

      paginate per_page: 4
      desc 'Get campaigns current user owns'
      get '/campaigns' do
        campaigns = paginate(Kaminari.paginate_array(current_user.campaigns.order('created_at DESC')))
        present campaigns
      end

      desc 'Get current user profile'
      get '/' do
        present current_user
        # present current_user: current_user, promotion: Promotion.valid
      end

      desc '促销送积分'
      get 'promotion' do
        present error: 0, promotion: Promotion.valid.try(:to_hash)
      end

      desc 'Update current user profile'
      params do
        requires :name        , type: String
        requires :real_name   , type: String
        requires :description , type: String
        requires :keywords    , type: String
        requires :campany_name, type: String
        optional :url         , type: String
      end
      put '/' do
        current_user.update_attributes declared(params)

        present current_user
      end

      desc 'Update current user password'
      params do
        requires :password                  , type: String
        requires :new_password              , type: String
        requires :new_password_confirmation , type: String
      end
      put '/password' do
        kol = current_user.kol
        if kol.valid_password? params[:password]
          if kol.reset_password params[:new_password], params[:new_password_confirmation]
            # TODO: in RESTful, update/delete success should return 204(no content).
            present current_user
          else
            error_unprocessable! "密码修改失败，请重试"
          end
        else
          error_unprocessable! '旧密码不正确'
        end
      end

      desc 'Update current user avatar'
      params do
        requires :avatar_url, type: String
      end
      put '/avatar' do
        current_user.update_attributes declared(params)

        present current_user
      end

    end
  end
end
