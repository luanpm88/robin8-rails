module API
  module V1
    class Feedbacks < Grape::API
      resources :feedbacks do
        params do
          requires :app_version, type: String
          requires :app_platform, type: String
          requires :os_version, type: String
          requires :device_model, type: String
          requires :content, type: String
          optional :screenshot
        end
        post 'create' do
          attrs = attributes_for_keys([:app_version, :app_platform, :os_version, :device_model, :content])
          feedback = Feedback.new
          feedback.attributes = attrs
          feedback.screenshot = params[:screenshot] if params[:screenshot]
          if params[:app_key] == 'robin8_feedbacks' && params[:kol_id].present?
            feedback.kol_id = params[:kol_id]
          elsif current_kol.present?
            feedback.kol_id = current_kol.id
          else
            return error_403!({error: 1, detail: '校验失败'})
          end
          if feedback.save
            present :error, 0
          else
            present :error, 1
            return error_403!({error: 1, detail: errors_message(feedback)})
          end
        end
      end
    end
  end
end
