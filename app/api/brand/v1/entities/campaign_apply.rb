module Brand
  module V1
    module Entities
      class CampaignApply < Entities::Base
        expose :kol, using: Entities::KolWithoutSocial
        # expose :campaign, using: Entities::Campaign
        expose :status, :agree_reason
        expose :img_status do |object, opts|
          object.campaign_invite.img_status
        end
        expose :screenshot do |object, opts|
          object.campaign_invite.screenshot.split(",") rescue []
        end
        expose :name do |object, opts|
          object.kol.name
        end
        expose :remark
        expose :images do |object|
          object.images.map(&:avatar_url)
        end
        expose :get_avail_click do |object, opts|
          object.campaign_invite.get_avail_click
        end
        expose :weixin_friend_count do |object, opts|
          object.kol.social_accounts.where(provider: 'wechat').maximum("followers_count")
        end
        expose :weibo_friend_count do |object, opts|
          object.kol.social_accounts.where(provider: 'weibo').maximum("followers_count")
        end
        # expose :weibo_homepage do |object, opts|
        #   social_account = object.kol.social_accounts.where(provider: 'weibo').order("followers_count desc").first
        #   social_account.homepage if social_account
        # end
        expose :brand_passed_count do |object, opts|
          object.campaign.brand_passed_applies.count
        end

        expose :kol_score do |object, opts|
          object.campaign_invite.kol_score
        end

        expose :brand_opinion do |object, opts|
          object.campaign_invite.brand_opinion
        end
      end
    end
  end
end
