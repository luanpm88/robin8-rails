module Brand
  module V1
    class UserAPI < Base
      include Grape::Kaminari

      paginate per_page: 3
      desc 'Get campaigns current user owns'
      get '/campaigns' do
        campaigns = paginate(Kaminari.paginate_array(current_user.campaigns))
        campaigns_count = current_user.campaigns.count
        present :campaigns, campaigns
        present :current_page, params[:page] if params[:page]
        present :total_page, campaigns_count / 2
        present :campaigns_count, campaigns_count
      end

    end
  end
end
