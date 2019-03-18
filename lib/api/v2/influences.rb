module API
  module V2
    class Influences < Grape::API
      resources :influences do
        get 'start' do
          if false
          # if current_kol
            kol_uuid = current_kol.get_kol_uuid
            current_kol.sync_tmp_identity_from_kol(kol_uuid)
            kol_identities = TmpIdentity.get_identities(kol_uuid)
            upload_contacts = current_kol.has_contacts
          else
            kol_uuid = SecureRandom.hex
            kol_identities = []
            upload_contacts = false
          end
          present :error, 0
          present :kol_uuid, kol_uuid
          present :uploaded_contacts, upload_contacts
          present :identities, kol_identities, with: API::V1::Entities::IdentityEntities::Summary
        end

        #第三方账号 价值
        params do
          requires :provider, type: String, values: ['weibo', 'wechat', 'qq']
          requires :uid, type: String
          requires :token, type: String
          requires :name, type: String
          requires :kol_uuid, type: String
          optional :serial_params, type: String
          optional :url, type: String
          optional :avatar_url, type: String
          optional :desc, type: String
          optional :followers_count, type: Integer
          optional :statuses_count, type: Integer

          optional :registered_at, type: DateTime
          optional :verified, type: Boolean
          optional :refresh_token, type: String
          optional :unionid, type: String

          optional :province, type: String
          optional :city, type: String
          optional :gender, type: String
          optional :is_vip, type: Boolean
          optional :is_yellow_vip, type: Boolean
        end
        post 'bind_identity' do
          if params[:provider] == 'weibo'
            required_attributes! [:followers_count, :statuses_count, :registered_at, :verified] #refresh_token
          elsif params[:provider] == 'wechat'
            required_attributes! [:unionid]
          end
          kol_uuid =  params[:kol_uuid]
          kol_identities = TmpIdentity.get_identities(kol_uuid)
          if kol_identities.collect{|identity| identity.uid }.include? params[:uid]
            present :error, 1
            present :detail, "该账号已经添加"
          else
            TmpIdentity.create_identity_from_app(params.merge({:from_type => 'app', :kol_uuid => kol_uuid }))
            kol_identities = TmpIdentity.get_identities(kol_uuid)
            present :error, 0
          end
          present :kol_uuid, kol_uuid
          present :identities, kol_identities, with: API::V1::Entities::IdentityEntities::Summary
        end

        #第三方账号 价值  解除绑定
        params do
          requires :provider, type: String, values: ['weibo', 'wechat', 'qq']
          requires :uid, type: String
          requires :kol_uuid, type: String
        end
        post 'unbind_identity' do
          kol_identities = TmpIdentity.get_identities(params[:kol_uuid])
          if kol_identities.collect{|identity| identity.uid }.include? params[:uid]
            TmpIdentity.find_by(:kol_uuid => params[:kol_uuid], :uid => params[:uid]).delete
            kol_identities = TmpIdentity.get_identities(params[:kol_uuid])
            present :error, 0
          else
            present :error, 1
            present :detail, "删除的账号不存在"
          end
          present :kol_uuid, params[:kol_uuid]
          present :identities, kol_identities, with: API::V1::Entities::IdentityEntities::Summary
        end

        #联系人  已经存在的用户 更新kol_contacts,新用户更新tmp_tmp_contacts
        params do
          requires :contacts, type: String
          optional :kol_uuid, type: String
        end
        post 'bind_contacts' do
          return  error_403!({error: 1, detail: '请登录'})    if current_kol.blank? && params[:kol_uuid].blank?
          Rails.logger.info "-----before: #{params[:kol_uuid]}----#{params[:contacts]}"
          if Rails.env.development?
            contacts = Kol.where("mobile_number is not null").limit(50).collect{|t| {'mobile' => t.mobile_number, 'name' => t.name || t.id}}
          else
            contacts = JSON.parse(params[:contacts])
          end
          Rails.logger.info "-----#{params[:kol_uuid]}----#{params[:contacts]}"
          return  error_403!({error: 1, detail: '联系人不存在或格式错误'})    if contacts.size == 0
          if current_kol.blank?
            TmpKolContact.add_contacts(params[:kol_uuid],contacts)
          else
            KolContact.add_contacts(params[:kol_uuid], contacts, current_kol.id)
          end
          present :error, 0
          present :kol_uuid, params[:kol_uuid]
        end

        # 计算总得分
        params do
          requires :kol_uuid, type: String
          requires :kol_mobile_model, type: String
          optional :kol_city, type: String
        end
        post 'cal_score' do
          kol_value = KolInfluenceValue.cal_and_store_score(current_kol.try(:id), params[:kol_uuid], params[:kol_city], params[:kol_mobile_model])
          if current_kol.present?
            # SyncInfluenceAfterSignUpWorker.perform_async(current_kol.id, params[:kol_uuid])
          end
          @campaigns = Campaign.recent_7.order_by_status.limit(5)
          present :error, 0
          present :kol_value, kol_value, with: API::V2::Entities::KolInfluenceValueEntities::Summary, kol: current_kol
          present :campaigns, @campaigns, with: API::V2::Entities::CampaignEntities::Summary
        end

        # 排名
        params do
          requires :kol_uuid, type: String
        end
        get 'rank' do
          kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
          if current_kol
            KolContact.update_joined_kols(current_kol.id)
            joined_contacts = KolContact.joined.where(:kol_id => current_kol.id)
            contacts = KolContact.order_by_exist.where(:kol_id => current_kol.id)
          else
            TmpKolContact.update_joined_kols(params[:kol_uuid])
            joined_contacts = TmpKolContact.joined.where(:kol_uuid => params[:kol_uuid])
            contacts = TmpKolContact.order_by_exist.where(:kol_uuid => params[:kol_uuid])
          end
          rank_index = joined_contacts.where("influence_score > '#{kol_value.influence_score}'").count   + 1
          present :error, 0
          present :joined_count, joined_contacts.size
          present :rank_index, rank_index
          present :last_influence_score, (KolInfluenceValue.before_kol_value(params[:kol_uuid], current_kol.try(:id), kol_value).influence_score  rescue nil)
          present :kol_value, kol_value, with: API::V2::Entities::KolInfluenceValueEntities::Summary, kol: current_kol
          present :contacts, contacts, with: API::V2::Entities::KolContactEntities::Summary
        end

        # 排名
        params do
          requires :kol_uuid, type: String
          requires :page, type: Integer
        end
        get 'rank_with_page' do
          present :error, 0
          if params[:page] == 1
            kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
            if current_kol
              KolContact.update_joined_kols(current_kol.id)
              joined_contacts = KolContact.joined.where(:kol_id => current_kol.id)
            else
              TmpKolContact.update_joined_kols(params[:kol_uuid])
              joined_contacts = TmpKolContact.joined.where(:kol_uuid => params[:kol_uuid])
            end
            rank_index = joined_contacts.where("influence_score > '#{kol_value.influence_score}'").count   + 1
            present :joined_count, joined_contacts.size
            present :rank_index, rank_index
            present :last_influence_score, (KolInfluenceValue.before_kol_value(params[:kol_uuid], current_kol.try(:id), kol_value).influence_score  rescue nil)
            present :kol_value, kol_value, with: API::V2::Entities::KolInfluenceValueEntities::Summary, kol: current_kol
          end
          if current_kol
            contacts = KolContact.order_by_exist.where(:kol_id => current_kol.id).page(params[:page]).per_page(20)
          else
            contacts = TmpKolContact.order_by_exist.where(:kol_uuid => params[:kol_uuid]).page(params[:page]).per_page(20)
          end
          present :contacts, contacts, with: API::V2::Entities::KolContactEntities::Summary
        end

        # 维度得分
        params do
          requires :kol_uuid, type: String
        end
        get 'item_detail' do
          kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
          item_rate, item_score = kol_value.get_item_scores
          present :error, 0
          present :diff_score, KolInfluenceValue.diff_score(params[:kol_uuid], current_kol.try(:id), kol_value)
          present :item_rate, item_rate, with: API::V2::Entities::KolInfluenceValueEntities::ItemRate
          present :history, KolInfluenceValueHistory.get_auto_history(params[:kol_uuid],  current_kol.try(:id))
        end

        # 提升影响力
        params do
          requires :kol_uuid, type: String
        end
        get 'upgrade' do
          kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
          rank_index = KolContact.joined.where(:kol_id => current_kol.id).where("influence_score > '#{kol_value.influence_score}'").count   + 1
          present :error, 0
          present :upgrade_notices, KolInfluenceValue::UpgradeNotices
          present :kol_value, kol_value, with: API::V2::Entities::KolInfluenceValueEntities::Summary, kol: current_kol
          present :rank_index, rank_index
          present :upgrade_info, current_kol, with: API::V1::Entities::KolEntities::Upgrade
        end

        # 分享分数
        params do
          requires :kol_uuid, type: String
        end
        put 'share' do
          kol_value = KolInfluenceValue.get_score(params[:kol_uuid])     rescue nil
          kol_value.increment!(:share_times)                             if kol_value
          present :error, 0
        end

        # invite
        params do
          requires :kol_uuid, type: String
          requires :mobile, type: String
        end
        post 'send_invite' do
          return error_403!({error: 1, detail: '你不能调用该接口'})      if !can_get_code?
          if  Influence::Util.is_mobile?(params[:mobile])
            invite_content = Emay::TemplateContent.get_invite_sms(TmpIdentity.get_name(params[:kol_uuid], current_kol.try(:id)))
            SmsMessage.send_to(params[:mobile], invite_content)
            TmpKolContact.record_send_invite(params[:kol_uuid], params[:mobile], current_kol)
            present :error, 0
          else
            return  error_403!({error: 1, detail: '非手机号不能发送短信'})
          end
        end
      end
    end
  end
end
