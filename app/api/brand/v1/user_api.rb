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
        campaigns = paginate(Kaminari.paginate_array(current_user.campaigns))
        present campaigns
      end

      desc 'Get current user profile'
      get '/' do
        present current_user
      end

      desc 'Update current user profile'
      params do
        requires :name        , type: String
        requires :real_name   , type: String
        requires :description , type: String
        requires :keywords    , type: String
        requires :url         , type: String
        requires :avatar_url  , type: String
      end
      put '/' do
        current_user.update_attributes declared(params)

        present current_user
      end

    end
  end
end
