module GeometryApi
  	module Entities
  	  module KolEntities
	      class Summary < Grape::Entity
          expose :mobile_number
          expose :signup_time do |kol|
  	        kol.created_at
          end
        end
      end
    end
  end