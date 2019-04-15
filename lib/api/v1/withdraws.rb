module API
  module V1
    class Withdraws < Grape::API
      resources :withdraws do
        before do
          authenticate!
        end

        params do
          optional :status, type: String, values: ['pending', 'approved' ,'rejected']
          optional :page, type: Integer
        end
        get '/' do
          if params[:status].present?
            withdraws = current_kol.withdraws.send(params[:status]).page(params[:page]).per_page(10)
          else
            withdraws = current_kol.withdraws.page(params[:page]).per_page(10)
          end
          present :error, 0
          to_paginate(withdraws)
          present :withdraws, withdraws, with: API::V1::Entities::WithdrawEntities::Summary
        end

        put 'update_is_read' do 
          present :error, 0
          withdraw = current_kol.withdraws.rejected.first
          withdraw.update_attributes(is_read: true) if withdraw.present?
          present :detail, "已读"
        end

      end
    end
  end
end
