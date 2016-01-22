module API
  module V1
    class Users < Grape::API
      resources :users do

        # 用户上传头像
        post 'avatar' do
          authenticate!
          required_attributes! [:avatar]
          current_user.avatar = params[:avatar]
          if current_user.save
            present :user, current_user, with: API::V1::Entities::UserEntities::Summary
          else
            error_403!({error: 1, detail: errors_message(current_user)})
          end
        end

        get "check_verify" do
          authenticate!
          present :auth_profile_state, current_user.auth_profile.aasm_state rescue ''
        end

      end
    end
  end
end
