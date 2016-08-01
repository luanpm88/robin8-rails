module API
  module V1_6
    module Entities
      module BigVEntities
        class Summary < Grape::Entity
          expose :name, :job_info
          expose :avatar_url do |big_v|
            big_v.get_avatar_url
          end
          expose :professions do |big_v|
            big_v.professions.collect{|t| {:id => t.id, :label => t.label} }
          end
        end

        class Detail < Grape::Entity
          expose :name, :job_info, :brief
          expose :avatar_url do |big_v|
            big_v.get_avatar_url
          end
          expose :app_city_label
          expose :professions do |big_v|
            big_v.professions.collect{|t| {:id => t.id, :label => t.label} }
          end
        end
      end
    end
  end
end
