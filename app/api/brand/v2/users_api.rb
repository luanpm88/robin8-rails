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

          desc 'update competitor status'
          params do
            requires :status,    type: Integer
            requires :id,        type: Integer
          end
          post 'competitor/:id' do
            competitor = current_user.competitors.find_by_id params[:id]
            if competitor
              competitor.update_column(:status, params[:status])
            else
              return {error: 1, detail: '数据错误，请确认'}
            end
          end


          desc 'create trademark'
          params do
            requires :name,       type: String
            requires :description,  type: String
          end

          post 'trademark' do
            current_user.trademarks.find_or_create_by(name: params[:name], description: params[:description])

            present current_user.trademarks, with: Entities::Trademark
          end

          desc 'update trademark status'
          params do
            requires :status,    type: Integer
            requires :id,        type: Integer
          end
          post 'trademark/:id' do
            trademark = current_user.trademarks.find_by_id params[:id]
            if trademark
              trademark.update_column(:status, params[:status])
            else
              return {error: 1, detail: '数据错误，请确认'}
            end
          end

        end
      end
    end
  end
end