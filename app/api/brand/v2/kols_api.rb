module Brand
  module V2
    class KolsAPI < Base
      group do
        before do
          authenticate!
        end

        resource :kols do

          desc 'pending tenders' #待合作
          params do
            requires :creation_id, type: Integer
          end
          get 'pending_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.by_status('pending')

            present @selected_kols, with: Entities::Kol
          end

          desc 'valid tenders' #合作中
          params do
            requires :creation_id, type: Integer
          end
          get 'cooperation_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.valid

            present @selected_kols, with: Entities::Kol
          end

          desc 'finished tender' #已完成
          params do
            requires :creation_id, type: Integer
          end
          get 'finished_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.by_status('finished')

            present @selected_kols, with: Entities::Kol
          end
        end
      end
    end
  end
end