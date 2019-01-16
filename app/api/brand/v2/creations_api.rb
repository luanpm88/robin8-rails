module Brand
  module V2
    class CreationsAPI < Base
      group do
        # before do
        #   authenticate!
        #   current_ability
        # end

        resource :creations do

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
              requires :img_url,        type: String
              requires :target, type: Hash do
                requires :category  ,   type: String
                requires :price_from,   type: Float
                requires :price_to,     type: Float
              end
              requires :terraces, type: Array do
                requires :terrace_id, type: Integer
                optional :exposure_value, type: Integer
              end
              optional :notice, type: String
            end
          end
          post do
            current_user = User.first
            target   = params[:creation].delete "target"
            terraces = params[:creation].delete "terraces"
            creation = params[:creation]
            creation = current_user.creations.new(
                       name:           creation[:name],
                       description:    creation[:description],
                       trademark_id:   creation[:trademark_id],
                       start_at:       creation[:start_at],
                       end_at:         creation[:end_at],
                       pre_kols_count: creation[:pre_kols_count],
                       pre_amount:     creation[:pre_amount],
                       status:         'pending'
                       img_url:        creation[:img_url]
            )

            if creation.save
              #target
              creation.targets_hash[:category]   = target[:category]
              creation.targets_hash[:price_from] = target[:price_from]
              creation.targets_hash[:price_to]   = target[:price_to]

              #terraces
              terraces.each do |attributes|
                ct = creation.creations_terraces.build(terrace_id: attributes[:terrace_id])
                ct.exposure_value = attributes[:exposure_value] if attributes[:exposure_value].present?
                ct.save
              end

              present creation
            else
              present creation.errors.messages
            end
          end
        end
      end
    end
  end
end
