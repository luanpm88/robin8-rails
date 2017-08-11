# coding: utf-8
module API
  module V2_0
    module Entities
      module InfluenceEntities
        class Industries < Grape::Entity
          expose :industry_name, :industry_score, :avg_posts, :avg_comments, :avg_likes
        end
      end
    end
  end
end
