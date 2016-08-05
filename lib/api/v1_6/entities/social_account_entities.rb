module API
  module V1_6
    module Entities
      module SocialAccountEntities
        class Summary < Grape::Entity
          expose :provider, :uid, :username, :homepage, :avatar_url, :brief, :followers_count, :friends_count,
                 :like_count, :reposts_count, :statuses_count
          expose :provider_name do |social_account|
            if social_account.provider ==  'weibo'
              '微博'
            elsif social_account.provider == 'public_wechat'
              '微信公众号'
            elsif social_account.provider == 'wechat'
              '微信'
            elsif social_account.provider == 'meipai'
              '美拍'
            elsif social_account.provider == 'miaopai'
              '秒拍'
            end
          end
          # expose :tags do |social_account|
          #   social_account.tags.collect{|t| {:id => t.id, :label => t.label} }
          # end
        end
      end
    end
  end
end
