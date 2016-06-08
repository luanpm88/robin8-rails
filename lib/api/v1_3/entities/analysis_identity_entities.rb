module API
  module V1_3
    module Entities
      module AnalysisIdentityEntities
        class Summary  < Grape::Entity
          expose :id, :provider, :nick_name, :name, :avatar_url, :location, :user_name
          expose :gender do |identity|
            if identity.gender == 'm'
              '男'
            elsif identity.gender == 'f'
              '女'
            else
              '未知'
            end
          end
          expose :valid do |identity|
            identity.valid_authorize?
          end
        end
      end
    end
  end
end
