module API
  module V3_0
    module Entities
      module KolEntities
        class SelectedKol < Grape::Entity
        	expose :id, :kol_id, :from_by, :status, :creation_id

        	expose :creation_name do |selected_kol|
        		selected_kol.creation.name
        	end
        end
      end
    end
  end
end