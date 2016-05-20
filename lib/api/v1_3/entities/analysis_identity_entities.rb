module API
  module V1_3
    module Entities
      module AnalysisIdentityEntities
        class Summary  < Grape::Entity
          expose :provider, :nickname, :username, :avatar_url, :location
          expose :gender do |identity|
            if identity.gender == 'm'
              '男'
            elsif identity.gender == 'f'
              '女'
            else
              '未知'
            end
          end
        end
      end
    end
  end
end
