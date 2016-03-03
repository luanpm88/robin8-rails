module Brand
  module V1
    class UserAPI < Base
      include Grape::Kaminari

      paginate per_page: 20
      desc 'Get campaigns current user owns'
      get '/campaigns' do
        campaigns = paginate(Kaminari.paginate_array(current_user.campaigns))
        present campaigns
      end

    end
  end
end
