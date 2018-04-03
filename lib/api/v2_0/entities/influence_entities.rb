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

        class Articles < Grape::Entity
          expose :post_id do |ele|
            ele['post_id']
          end
          expose :avatar_url do |ele|
            ele['avatar_url']
          end
          expose :user_name do |ele|
            ele['profile_name']
          end
          expose :post_date do |ele|
            Time.at(ele['post_date'].to_i).to_s
          end
          expose :title do |ele|
            ele['title']
          end
          expose :content do |ele|
            ele['content_id']
          end
          expose :pics do |ele|
            # ele['pic_content'].split(',').inject({}){|h, pic| h[pic] = ElasticArticle.weibo_pics(pic); h}
            ElasticArticle.weibo_pic_ary(ele['pic_content'])
          end
          expose :tag do |ele|
            ele['top_industry']
          end
          expose :reads_count do |ele|
            ele['reads'].to_i
          end
          expose :likes_count do |ele|
            ele['likes'].to_i
          end
          expose :collects_count do |ele|
            ele['collects'].to_i
          end
          expose :forwards_count do |ele|
            ele['forwards'].to_i
          end
        end
      end
    end
  end
end
