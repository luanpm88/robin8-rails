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
            optional :status,       type: Integer
            optional :name,         type: String
            optional :short_name,   type: String
            requires :id,           type: Integer
          end
          post 'competitor/:id' do
            competitor = current_user.competitors.find_by_id params[:id]

            return {error: 1, detail: '数据错误，请确认'} unless competitor

            competitor.name       = params[:name]       if params[:name]
            competitor.short_name = params[:short_name] if params[:short_name]
            competitor.status     = params[:status]     if params[:status]
            
            competitor.save

            present error: 0, alert: '更新成功'
          end


          desc 'create trademark'
          params do
            requires :name,       type: String
            requires :description,  type: String
          end

          post 'trademark' do
            current_user.trademarks.where(status: 1).update_all(status: 0)
            trademark = current_user.trademarks.find_or_initialize_by(name: params[:name], description: params[:description])
            trademark.status = 1 if trademark.valid?
            trademark.save

            present current_user.trademarks.active, with: Entities::Trademark
          end

          desc 'update trademark status'
          params do
            optional :status,       type: Integer
            optional :name,         type: String
            optional :description,  type: String
            requires :id,           type: Integer
          end
          post 'trademark/:id' do
            trademark = current_user.trademarks.active.find_by_id params[:id]

            return {error: 1, detail: '数据错误，请确认'} unless trademark

            current_user.trademarks.where(status: 1).update_all(status: 0) if params[:status] && params[:status].to_i == 1

            trademark.name        = params[:name]        if params[:name]
            trademark.description = params[:description] if params[:description]
            trademark.status      = params[:status]      if params[:status]

            trademark.save

            present error: 0, alert: '更新成功'
          end

        end
      end
    end
  end
end