# coding: utf-8
module API
  module V2_0
    module Entities
      module KolOverviewEntities
        class Campaigns < Grape::Entity
          expose :running_count do |kol|
            brand_user = kol.find_or_create_brand_user
            brand_user.campaigns.where(:status => ['agreed', "executing"]).size
          end
          expose :completed_count do |kol|
            brand_user = kol.find_or_create_brand_user
            brand_user.campaigns.where(:status => ['executed', "settled"]).size
          end
          expose :had_shared_today do |kol|
            last_campaign_invite = kol.campaign_invites.last
            last_campaign_invite.nil? ? false : last_campaign_invite.created_at.to_date == Date.today
          end
          expose :income_via_share do |kol|
            kol.campaign_total_income
          end
        end

        class CpsShare < Grape::Entity
          expose :running_count do |kol|
            kol.cps_article_shares.includes(:cps_articles).size
          end
          expose :sold_count do |kol|
            kol.cps_promotion_orders.cps_promotion_order_items.sum(:quantity)
          end
          expose :income_via_share do |kol|
            kol.income_transactions.where(item_type: 'CpsPromotionOrder').sum(:credits)
          end
          expose :had_shared_today do |kol|
            last_article_share = kol.cps_article_shares.last
            last_article_share.nil? ? false : last_article_share.created_at.to_date == Date.today
          end
        end

        class KolInvitations < Grape::Entity
          expose :running_count do |kol|
            kol.registered_invitations.pending.size
          end
          expose :completed_count do |kol|
            kol.registered_invitations.completed.size
          end
          expose :income_via_invitation do |kol|
            kol.invite_transactions.sum(:credits).round(2)
          end
        end

        class FriendsPercentage < Grape::Entity
          expose :kol_id do |ri|
            ri.invitee_id
          end
          expose :kol_name do |ri|
            ri.invitee.name
          end
          expose :campaign_invites_count do |ri|
            ri.invitee.campaign_invites.count
          end
          expose :amount do |ri, options|
             options[:current_kol].friend_amount(ri.invitee)
          end
        end
        
      end
    end
  end
end
