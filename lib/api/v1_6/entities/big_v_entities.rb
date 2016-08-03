module API
  module V1_6
    module Entities
      module BigVEntities
        class Summary < Grape::Entity
          expose :id, :name, :job_info
          expose :professions do |big_v|
            big_v.professions.collect{|t| {:name => t.name, :label => t.label} }
          end
          expose :avatar_url do |big_v|
            big_v.get_avatar_url
          end
        end

        class Detail < Grape::Entity
          expose :id, :name, :job_info, :desc, :app_city_label
          expose :avatar_url do |big_v|
            big_v.get_avatar_url
          end
          expose :professions do |big_v|
            big_v.professions.collect{|t| {:name => t.name, :label => t.label} }
          end
        end
      end
    end
  end
end
