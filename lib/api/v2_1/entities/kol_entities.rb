module API
  module V2_1
    module Entities
      module KolEntities
        class BaseInfo < Grape::Entity
          expose :id, :name, :mobile_number, :email, :age, :age_show, :gender, :job_info, :completed_rate

          expose :avatar_url do |kol|
            kol.avatar.url(200)
          end
          expose :circles do |kol|
            API::V2_1::Entities::BaseInfoEntities::Circle.represent kol.circles
          end
          expose :is_big_v do |kol|
            kol.is_big_v?
          end
          expose :is_creator do |kol|
            kol.creator.try(:status) == 1
          end
          expose :weibo_account do |kol|
            WeiboAccount.represent kol.weibo_account
          end
          expose :public_wechat_account do |kol|
            PublicWechatAccount.represent kol.public_wechat_account
          end
          expose :creator do |kol|
            Creator.represent kol.creator
          end
          expose :social_accounts do |kol|
            API::V1_6::Entities::SocialAccountEntities::Summary.represent kol.social_accounts
          end
        end

        class Creator < Grape::Entity
          expose :id, :price, :video_price, :fans_count, :gender, :age_range, :content_show, :remark

          expose :circles do |creator|
            API::V2_1::Entities::BaseInfoEntities::Circle.represent creator.circles
          end
          expose :terraces do |creator|
            API::V2_1::Entities::BaseInfoEntities::Terrace.represent creator.terraces
          end
          expose :cities do |creator|
            creator.cities.map(&:show_name)
          end
        end

        class WeiboAccount < Grape::Entity
          expose :id, :nickname, :auth_type, :fwd_price, :price, :live_price, :quote_expired_at,
                 :fans_count, :gender, :countent_show, :remark

          expose :circles do |weibo_account|
            API::V2_1::Entities::BaseInfoEntities::Circle.represent weibo_account.circles
          end
        end

        class PublicWechatAccount < Grape::Entity
          expose :id, :nickname, :price, :mult_price, :sub_price, :n_price, :quote_expired_at,
                 :fans_count, :gender, :content_show, :remark

          expose :circles do |public_wechat_account|
            API::V2_1::Entities::BaseInfoEntities::Circle.represent public_wechat_account.circles
          end
        end

      end
    end
  end
end
