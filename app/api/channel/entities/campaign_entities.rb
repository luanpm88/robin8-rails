module Channel
	module Entities
		module CampaignEntities
			class Campaign < Grape::Entity
			  expose :id , :name , :description , :remark ,:img_url
			end
		end
	end
end