module API
  module V2_1
    module Entities
      module KolEntities
        class BaseInfo < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }

          expose :id, :name, :mobile_number, :email, :gender, :job_info, :completed_rate,
                 :wechat_friends_count

          expose :avatar_url do |kol|
            kol.avatar.url(200)
          end
          with_options(format_with: :iso_timestamp) do
            expose :birthday
          end
          expose :circles do |kol|
            API::V2_1::Entities::BaseInfoEntities::Circle.represent kol.circles
          end
          expose :is_big_v do |kol|
            kol.is_new_big_v?
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
          expose :id, :price, :video_price, :fans_count, :gender, :age_range, :content_show, :remark, :status

          expose :circles do |creator|
            API::V2_1::Entities::BaseInfoEntities::Circle.represent creator.circles
          end
          expose :terraces do |creator|
            API::V2_1::Entities::BaseInfoEntities::Terrace.represent creator.terraces
          end
          expose :cities do |creator|
            creator.cities.map(&:name)
          end
        end

        class WeiboAccount < Grape::Entity
          expose :id, :nickname, :auth_type, :fwd_price, :price, :live_price, :quote_expired_at,
                 :fans_count, :gender, :content_show, :remark, :status

          expose :circles do |weibo_account|
            API::V2_1::Entities::BaseInfoEntities::Circle.represent weibo_account.circles
          end
          expose :cities do |weibo_account|
            weibo_account.cities.map(&:name)
          end
        end

        class PublicWechatAccount < Grape::Entity
          expose :id, :nickname, :price, :mult_price, :sub_price, :n_price, :quote_expired_at,
                 :fans_count, :gender, :content_show, :remark, :status

          expose :circles do |public_wechat_account|
            API::V2_1::Entities::BaseInfoEntities::Circle.represent public_wechat_account.circles
          end
          expose :cities do |public_wechat_account|
            public_wechat_account.cities.map(&:name)
          end
        end

        class Brief < Grape::Entity
          expose :id, :name, :vote_ranking

          expose :avatar_url do |kol|
            kol.avatar.url(200)
          end

          expose :is_hot do |kol|
            kol.redis_votes_count.value
          end
        end

        class Voter < Grape::Entity
          expose :voter_id, :count
          expose :updated_at do |voter|
            voter.updated_at.to_i
          end
          expose :voter_name do |voter|
            voter.voter.name
          end
          expose :voter_avatar do |voter|
            voter.voter.avatar_url
          end
        end

      end
    end
  end
end
