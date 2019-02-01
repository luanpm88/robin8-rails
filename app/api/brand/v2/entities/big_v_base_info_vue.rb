module Brand
  module V2
    module Entities
      class BigVBaseInfoVue < Entities::Base
        expose :avatar_url do |obj|
        	obj.avatar_url
        end
        expose :profile_name do |obj|
        	obj.name
        end
        expose :industries do |obj|
        	obj.tags.map(&:name)
        end
      end
    end
  end
end