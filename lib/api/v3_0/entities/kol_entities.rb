module API
  module V3_0
    module Entities
      module KolEntities
        class SelectedKol < Grape::Entity
        	expose :id, :kol_id, :from_by, :status, :creation_id

        	expose :creation_name do |selected_kol|
        		selected_kol.creation.name
        	end

          expose :status_zh do |selected_kol|
            CreationSelectedKol::STATUS[selected_kol.status.to_sym]
          end
        end
      end
    end
  end
end