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
              requires :target, type: Hash do
                requires :tags   , type: String
                requires :price,   type: Float
                requires :age    , type: String
                requires :gender , type: String
                requires :region , type: String
              end
              requires :creations_terraces_attributes, type: hash do 
                requires :exposure_value, type: Integer
                requires :terrace_id, type: Integer
              end
              optional :notice, type: String
            end
          end
          post do
            creation       = current_user.creations.new params[:creation]
            creation.image = params[:image]

            creation.save

            params[:exposures_array].each do |_hash|
              .create()
            end
            if creation
              present creation
            else
              present creation.first_error_message
            end
          end
        end
      end
    end
  end
end
