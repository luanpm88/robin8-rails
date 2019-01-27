module Brand
  module V2
    class CreationsAPI < Base
      group do
        before do
          # authenticate!
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
              requires :name,           type: String
              requires :description,    type: String
              requires :trademark_id,   type: Integer
              requires :start_at,       type: DateTime
              requires :end_at,         type: DateTime
              requires :pre_kols_count, type: Integer
              requires :pre_amount,     type: Float
              # requires :img_url,        type: String
              requires :target, type: Hash do
                requires :industries,   type: String # 'a,b,c,d'
                requires :price_from,   type: Float
                requires :price_to,     type: Float
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
            current_user = User.find 829
            target        = params[:creation].delete "target"
            terraces      = params[:creation].delete "terraces"
            selected_kols = params[:creation].delete 'selected_kols'
            creation      = params[:creation]
            creation      = current_user.creations.new(
                            name:           creation[:name],
                            description:    creation[:description],
                            trademark_id:   creation[:trademark_id],
                            start_at:       creation[:start_at],
                            end_at:         creation[:end_at],
                            pre_kols_count: creation[:pre_kols_count],
                            pre_amount:     creation[:pre_amount],
                            # img_url:        creation[:img_url]
            )

            if creation.save
              #target
              creation.targets_hash[:industries]   = target[:industries]
              creation.targets_hash[:price_from] = target[:price_from]
              creation.targets_hash[:price_to]   = target[:price_to]

              #terraces
              terraces.each do |attributes|
                if Terrace.find_by_id(attributes[:terrace_id])
                  ct = creation.creations_terraces.build(terrace_id: attributes[:terrace_id])
                  ct.exposure_value = attributes[:exposure_value] if attributes[:exposure_value].present?
                  ct.save
                end
              end

              #selected_kol
              if selected_kols
                selected_kols.each do |attributes|
                  creation.creation_selected_kols.create(
                    plateform_name: attributes[:plateform_name],
                    plateform_uuid: attributes[:plateform_uuid],
                    name:           attributes[:name],
                    avatar_url:     attributes[:avatar_url],
                    desc:           attributes[:desc]
                  )
                end
              end
              present creation
            else
              present creation.errors.messages
            end
          end

          desc 'creation show'
          params do
            requires :id, type: Integer
          end
          get ':id' do
            creation = Creation.find_by(id: params[:id])

            return {error: 1, detail: 'not found'} unless creation

            present creation
          end


          desc 'creation list'
          get '/' do 
            creations = current_user.creations.order(updated_at: :desc)

            present creations, with: Entities::Creation
          end




        end
      end
    end
  end
end
