module Brand
  module V2
    class KolsAPI < Base
      group do
        before do
          authenticate!
        end

        resource :kols do

          desc 'pending tender'
          params do
            requires :creation_id, type: Integer
          end
          get 'pending_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.is_quoted

            present @selected_kols, with: Entities::Kol, status: 'pending'
          end

          desc 'unpay tender'
          params do
            requires :creation_id, type: Integer
          end
          get 'unpay_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.is_quoted

            present @selected_kols, with: Entities::Kol, status: 'unpay'
          end

          desc 'paid tender'
          params do
            requires :creation_id, type: Integer
          end
          get 'paid_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.is_quoted

            present @selected_kols, with: Entities::Kol, status: 'paid'
          end
        end
      end
    end
  end
end