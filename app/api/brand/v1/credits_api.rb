module Brand
  module V1
    class CreditsAPI < Base
      include Grape::Kaminari
      before do
        authenticate!
      end

      resource :credits do
        paginate per_page: 10
        get "/" do
          credits = paginate(Kaminari.paginate_array(current_user.credits.includes(:resource).order('created_at DESC')))
          present credits
        end
      end
    end
  end
end
