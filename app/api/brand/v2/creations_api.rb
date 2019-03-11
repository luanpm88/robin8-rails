module Brand
  module V2
    class CreationsAPI < Base
      group do
        include Grape::Kaminari

        before do
          authenticate! unless @options[:path].first == 'upload_image'
        end

        resource :creations do

          desc 'upload image'
          post 'upload_image' do 
            res = Uploader::FileUploader.image_uploader params[:image]
            present res
          end

          desc 'create creation'
          params do
            requires :creation, type: Hash do
              optional :id,             type: Integer
              requires :name,           type: String
              requires :description,    type: String
              requires :trademark_id,   type: Integer
              requires :start_at,       type: DateTime
              requires :end_at,         type: DateTime
              requires :pre_kols_count, type: Integer
              requires :pre_amount,     type: Float
              requires :img_url,        type: String
              requires :target, type: Hash do
                requires :industries,   type: String # 'a,b,c,d'
                requires :price_from,   type: Integer
                requires :price_to,     type: Integer
              end
              requires :terraces, type: Array do
                requires :terrace_id, type: Integer
                optional :exposure_value, type: Integer
              end
              optional :selected_kols, type: Array do
                requires :plateform_name, type: String
                requires :plateform_uuid, type: String 
                requires :name,           type: String
                requires :avatar_url,     type: String 
                requires :desc,           type: String
              end
              optional :notice, type: String
            end
          end
          post do
            c = current_user.creations.find_or_initialize_by(id: params[:id])

            return {error: 1, detail: '活动不能修改'} if c.new_record? && !c.can_edit?

            c.name            = params[:creation][:name]
            c.description     = params[:creation][:description]
            c.trademark_id    = params[:creation][:trademark_id]
            c.start_at        = params[:creation][:start_at].to_formatted_s(:db)
            c.end_at          = params[:creation][:end_at].to_formatted_s(:db)
            c.pre_kols_count  = params[:creation][:pre_kols_count]
            c.pre_amount      = params[:creation][:pre_amount]
            c.img_url         = params[:creation][:img_url]
            c.notice          = params[:creation][:notice]
            c.status          = "pending"
            c.save

            c.reload
            # binding.pry
            c.targets_hash[:industries] = params[:creation][:target][:industries]
            c.targets_hash[:price_from] = params[:creation][:target][:price_from]
            c.targets_hash[:price_to]   = params[:creation][:target][:price_to]

            c.creations_terraces.delete_all # 平台必选，直接清空
            params[:creation][:terraces].each do |_hash|
              c.creations_terraces.create(
                terrace_id:     _hash[:terrace_id],
                exposure_value: _hash[:exposure_value]
              ) if Terrace.find_by_id(_hash[:terrace_id])
            end
            
            c.creation_selected_kols.delete_all # kol可选，直接清空
            params[:creation][:selected_kols].each do |_hash|
              kol = c.creation_selected_kols.find_or_initialize_by(plateform_name: _hash[:plateform_name], plateform_uuid: _hash[:plateform_uuid])
              kol.name        = _hash[:name]
              kol.avatar_url  = _hash[:avatar_url]
              kol.desc        = _hash[:desc]
              kol.kol_id      = _hash[:kol_id]
              kol.save
            end

            present c.reload
          end

          desc 'creation show'
          params do
            requires :id, type: Integer
          end
          get ':id' do
            creation = current_user.creations.find_by(id: params[:id])

            return {error: 1, detail: 'not found'} unless creation

            present creation
          end

          # paginate per_page: 10
          desc 'creation list'
          get '/' do
            creations = paginate(Kaminari.paginate_array(current_user.creations.order(updated_at: :desc)))

            present creations, with: Entities::Creation
          end


        end
      end
    end
  end
end
