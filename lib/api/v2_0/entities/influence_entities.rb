# coding: utf-8
module API
  module V2_0
    module Entities
      module InfluenceEntities
        class Industries < Grape::Entity
          expose :industry_name, :industry_score#, :avg_posts, :avg_comments#, :avg_likes
          expose :avg_likes do |industry|
            industry.avg_likes.round(2)
          end
          expose :avg_posts do |industry|
            industry.avg_posts.round(2)
          end
          expose :avg_comments do |industry|
            industry.avg_comments.round(2)
          end

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
