module Brand
  module V2
    module Entities
      class BigVCreationVue < Entities::Base
      	expose :id
        expose :title do |obj|
        	obj.creation.name
        end
        expose :date do |obj|
        	obj.updated_at.strftime('%F')
        end
        expose :amount do |obj|
        	"#{obj.tenders.sum(:price).to_f}RMB"
        end
      end
    end
  end
end