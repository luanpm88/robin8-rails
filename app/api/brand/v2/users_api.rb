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
          post 'collect_kol' do
            current_user = User.first
            ck = current_user.collected_kols.build(plateform_uuid: params[:plateform_uuid])
            if ck.save
              present current_user
            else
              present ck.errors.messages
            end
          end


          desc 'create Competitor'
          params do
            requires :competitors, type: Array do 
              requires :name,       type: String
              requires :short_name,  type: String
            end
          end

          post 'competitor' do
            params[:competitors].each do |attributes|
              current_user.competitors.find_or_create_by(name: attributes[:name], short_name: attributes[:short_name])
            end

            present current_user.competitors, with: Entities::Competitor
          end



          desc 'brand Competitors'

          get 'competitors' do
            present current_user.competitors, with: Entities::Competitor
          end

        end
      end
    end
  end
end