module API
  module V1
    class Feedbacks < Grape::API
      resources :feedbacks do
        before do
          authenticate!
        end

        # get '/' do
        #   if params[:status].present?
        #     withdraws = current_kol.withdraws.send(params[:status]).page(params[:page]).per_page(10)
        #   else
        #     withdraws = current_kol.withdraws.page(params[:page]).per_page(10)
        #   end
        #   present :error, 0
        #   to_paginate(withdraws)
        #   present :withdraws, withdraws, with: API::V1::Entities::WithdrawEntities::Summary
        # end


        params do
          requires :app_version, type: String
          requires :os_version, type: String
          requires :device_model, type: String
          requires :content, type: String
        end
        post 'create' do
          attrs = attributes_for_keys([:app_version, :os_version, :device_model, :content])
          feedback = Feedback.new
          feedback.attributes = attrs
          feedback.kol_id = current_kol.id
          if feedback.save
            present :error, 0
            present :detail, 0
          else
            present :error, 1
            error_403!({error: 1, detail: errors_message(feedback)})
          end
        end
      end
    end
  end
end
