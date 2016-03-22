module API
  module V1
    class Feedbacks < Grape::API
      resources :feedbacks do
        before do
          authenticate!
        end

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
