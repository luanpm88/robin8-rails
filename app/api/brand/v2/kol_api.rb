module Brand
  module V2
    class KolsAPI < Base
      group do
        before do
          authenticate!
          current_ability
        end

        resource :KolsAPI do

          desc 'pending tender'
          params do
            requires :creation_id, type: Integer
          end
          get 'pending_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.is_quoted
            present @selected_kols, with: Entities::Kol
          end
        end
      end
    end
  end
end