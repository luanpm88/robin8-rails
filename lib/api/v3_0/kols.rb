# coding: utf-8
module API
  module V3_0
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate!
        end

        # get my tenders
        params do
        	requires :status, type: String, values: %w(pending passed rejected)
          requires :page,   type: Integer
        end
        get ':id/tenders' do
          # current_user = Kol.find 109050
          list =  if params[:status] == 'passed'
                    current_user.creation_selected_kols.valid
                  else
                    current_user.creation_selected_kols.by_status(params[:status])
                  end

        	list = list.page(params[:page]).per_page(10)

        	present :error, 0
        	present :list,  list, with: API::V3_0::Entities::KolEntities::SelectedKol
      	end

      end
    end
  end
end