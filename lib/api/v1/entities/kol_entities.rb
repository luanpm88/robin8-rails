module API
  module V1
    module Entities
      module KolEntities
        class Summary < Grape::Entity
          expose :id, :email, :mobile_number, :gender, :date_of_birthday,
                 :alipay_account, :alipay_name, :desc, :age, :weixin_friend_count, :id_card, :kol_role, :role_apply_status, :role_check_remark
          expose :name do  |kol|
            kol.name || Kol.hide_real_mobile_number(kol.mobile_number)
          end
          expose :country do |kol|
            kol.app_country
          end
          expose :app_city
          expose :app_city_label
          expose :avatar_url do |kol|
            kol.avatar.url(200)  rescue ''
          end
          expose :tags do |kol|
            kol.tags.collect{|t| {:name => t.name, :label => t.label} }
          end
          expose :influence_score
          expose :selected_like_articles do |kol|
            kol.article_actions.count > 0
          end
          expose :issue_token do |kol|
            kol.get_issue_token
          end
          expose :kol_uuid do |kol|
            kol.get_kol_uuid
          end
          expose :rongcloud_token do |kol|
            kol.get_rongcloud_token
          end

          expose :put_address do |kol|
            kol.e_wallet_account.try(:token)
          end
        end

        class Account < Grape::Entity
          expose :amount do |kol|
            kol.amount.round(2)  rescue 0
          end
          expose :frozen_amount do |kol|
            kol.frozen_amount.round(2)  rescue 0
          end
          expose :avail_amount do |kol|
            (kol.amount - kol.frozen_amount).round(2)  rescue 0
          end
          expose :total_income do |kol|
            kol.total_income.round(2)
          end
          expose :total_expense do |kol|
            kol.total_expense.round(2)
          end
          expose :total_withdraw do |kol|
            kol.total_withdraw.round(2)
          end
          expose :today_income do |kol|
            kol.today_income.round(2)
          end
          expose :verifying_income do |kol|
            kol.verifying_income.round(2)
          end
          expose :total_amount do |kol|
            (kol.amount + kol.frozen_amount).round(2)
          end
          expose :remark do |kol|
            kol.withdraws.rejected.first.try(:reject_reason) rescue nil
          end
        end

        #左边导航
        class Primary < Grape::Entity
          # key 没改，内容已经变成所有收入
          expose :influence_score  do |kol|
            kol.influence_score
          end
          expose :today_income  do |kol|
            kol.total_income.round(2)  + kol.verifying_income.round(2)
          end
          expose :unread_count do |kol|
            kol.unread_messages.count
          end
          expose :waiting_upload_count do |kol|
            kol.campaign_invites.waiting_upload.count
          end
          expose :verifying_count do |kol|
            kol.campaign_invites.verifying.count
          end
          expose :settled_count do |kol|
            kol.campaign_invites.completed.count
          end
        end

        class MessageStat < Grape::Entity
          expose :unread_message_count do |kol|
            kol.unread_messages.count
          end
          expose :new_income do |kol|
            kol.new_income.round(1)
          end
        end

        class Common < Grape::Entity
          expose :email, :mobile_number
          expose :name do  |kol|
            kol.name || Kol.hide_real_mobile_number(kol.mobile_number)
          end
          expose :avatar_url do |kol|
            (kol.avatar.url(200)  rescue nil) || kol.read_attribute(:avatar_url)
          end
          expose :rongcloud_token do |kol|
            kol.get_rongcloud_token
          end
        end

        class Upgrade < Grape::Entity
          expose :campaign_count do |kol|
            kol.campaign_invites.completed.size
          end
          expose :identity_count do |kol|
            kol.identities.size
          end
          expose :has_contacts
        end


        class InviteeSummary < Grape::Entity
          expose :id
          expose :name do  |kol|
            kol.name.present? ? kol.safe_name : Kol.hide_real_mobile_number(kol.mobile_number)
          end
          expose :avatar_url do |kol|
            (kol.avatar.url(200)  rescue nil) || kol.read_attribute(:avatar_url)
          end
        end

        class InviteeDetail < Grape::Entity
          expose :id, :app_city_label, :influence_score
          expose :name do  |kol|
            kol.name.present? ? kol.name : Kol.hide_real_mobile_number(kol.mobile_number)
          end
          expose :avatar_url do |kol|
            (kol.avatar.url(200)  rescue nil) || kol.read_attribute(:avatar_url)
          end
          expose :tags do |kol|
            kol.tags.collect{|t|  t.label }
          end
          expose :influence_level do |kol|
            if kol.influence_score == -1
              nil
            else
              Influence::Value.get_influence_level(kol.influence_score)
            end
          end
          expose :rank_index do |kol|
            if kol.influence_score == -1
              nil
            else
              KolContact.joined.where(:kol_id => kol.id).where("influence_score > '#{kol.influence_score}'").count + 1
            end
          end
        end
      end
    end
  end
end
