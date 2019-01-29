module Brand
  module V2
    class KolsAPI < Base
      group do
        before do
          authenticate!
        end

        resource :kols do

          desc 'pending tenders'
          params do
            requires :creation_id, type: Integer
          end
          get 'pending_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.pending

            present @selected_kols, with: Entities::Kol
          end

          desc 'cooperation tenders'
          params do
            requires :creation_id, type: Integer
          end
          get 'cooperation_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.cooperation

            present @selected_kols, with: Entities::Kol
          end

          desc ' tender'
          params do
            requires :creation_id, type: Integer
          end
          get 'paid_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.by_status('finished')

            present @selected_kols, with: Entities::Kol
          end
        end
      end
    end
  end
end