module Brand
  module V2
    class UsersAPI < Base
      group do
        before do
          authenticate!
        end

        resource :users do

          desc 'collect kols'
          params do
            requires :plateform_uuid, type: String
          end
          put 'collect_kol' do
            current_user = User.first
            ck = current_user.collected_kols.build(plateform_uuid: params[:plateform_uuid])
            if ck.save
              present current_user
            else
              present ck.errors.messages
            end
          end

        end
      end
    end
  end
end