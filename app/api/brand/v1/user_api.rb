module Brand
  module V1
    class UserAPI < Base

      desc 'Get campaigns current user owns'
      get '/campaigns' do
        present current_user.campaigns
      end

    end
  end
end
