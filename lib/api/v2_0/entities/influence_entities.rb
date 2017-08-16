# coding: utf-8
module API
  module V2_0
    module Entities
      module InfluenceEntities
        class Industries < Grape::Entity
          expose :industry_name, :industry_score, :avg_posts, :avg_comments, :avg_likes
        end

        class SimilarKols < Grape::Entity
          expose :id do |kol_id|
            kol_id
          end
          expose :avatar_url do |kol_id|
            Kol.find(kol_id).identities.where(provider: 'weibo').first.avatar_url rescue ''
          end
        end
      end
    end
  end
end
