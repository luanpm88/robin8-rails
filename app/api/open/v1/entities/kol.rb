module Open
  module V1
    module Entities
      module Kol
        class Summary < Grape::Entity
          expose :id, :name, :job_info

          expose :tags do |kol|
            kol.tags.collect{|t| {:name => t.name, :label => t.label} }
          end

          expose :avatar_url do |kol|
            kol.get_avatar_url
          end

          expose :social_accounts, using: Open::V1::Entities::SocialAccount::Summary
        end

        class Detail < Grape::Entity
          expose :id, :name, :job_info, :desc, :app_city_label, :kol_role,
                 :role_apply_status, :role_check_remark, :gender, :age

          expose :avatar_url do |kol|
            kol.get_avatar_url
          end

          expose :tags do |kol|
            kol.tags.collect{|t| {:name => t.name, :label => t.label} }
          end

          expose :social_accounts, using: Open::V1::Entities::SocialAccount::Summary
          expose :kol_shows,       using: Open::V1::Entities::KolShow::Summary
          expose :kol_keywords,    using: Open::V1::Entities::KolKeyword::Summary do |kol|
            keywords = kol.kol_keywords
            keywords = kol.tags.map do |tag|
              KolKeyword.new(:keyword => tag.label)
            end if keywords.blank?
            keywords
          end
        end
      end
    end
  end
end
