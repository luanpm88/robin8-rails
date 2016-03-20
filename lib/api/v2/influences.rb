module API
  module V2
    class Influences < Grape::API
      resources :influences do
        get 'start' do
          if current_kol
            current_kol.reset_kol_uuid
            kol_uuid = current_kol.kol_uuid
          else
            kol_uuid = SecureRandom.hex
          end
          present :error, 0
          present :kol_uuid, kol_uuid
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
            required_attributes! [:followers_count, :statuses_count, :registered_at, :verified]
          else
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
          present :kol_identities, kol_identities, with: API::V1::Entities::IdentityEntities::Summary
        end

        #第三方账号 价值  解除绑定
        params do
          requires :provider, type: String, values: ['weibo', 'wechat']
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
          present :kol_uuid, kol_uuid
          present :kol_identities, kol_identities, with: API::V1::Entities::IdentityEntities::Summary
        end

        #联系人
        params do
          requires :contacts, type: String
          requires :kol_uuid, type: String
        end
        post 'bind_contacts' do
          if Rails.env.development?
            contacts = Kol.where("mobile_number is not null").limit(40).collect{|t| {'mobile' => t.mobile_number, 'name' => t.name || t.id}}
          else
            contacts = JSON.parse(params[:contacts])
          end
          return  error_403!({error: 1, detail: '联系人不存在或格式错误'})    if contacts.size == 0
          kol_uuid = params[:kol_uuid]
          TmpKolContact.add_contacts(kol_uuid,contacts)
          present :error, 0
          present :kol_uuid, kol_uuid
        end


        # 计算总得分
        params do
          requires :kol_uuid, type: String
          requires :kol_mobile_model, type: String
          optional :kol_city, type: String
        end
        post 'cal_score' do
          influence_score = Influence::Value.cal_total_score(params[:kol_uuid], params[:kol_city], params[:kol_mobile_model])
          SyncInfluenceAfterSignUpWorker.perform_async(current_kol.id, params[:kol_uuid])     if current_kol.present?
          @campaigns = Campaign.order_by_status.limit(5)
          present :error, 0
          present :kol_uuid, params[:kol_uuid]
          present :influence_score, influence_score
          present :influence_level, Influence::Value.get_influence_level(influence_score)
          present :cal_time, Influence::Value.get_cal_time(params[:kol_uuid])
          present :name, TmpIdentity.get_name(params[:kol_uuid])
          present :avatar_url, TmpIdentity.get_avatar_url(params[:kol_uuid])
          present :campaigns, @campaigns, with: API::V2::Entities::CampaignEntities::Summary
        end

        # 排名
        params do
          requires :kol_uuid, type: String
        end
        get 'rank' do
          joined_contacts = TmpKolContact.joined.where(:kol_uuid => params[:kol_uuid])
          influence_score = Influence::Value.get_total_score(params[:kol_uuid])
          rank_index = joined_contacts.where("influence_score > '#{influence_score}'").count
          rank_index = rank_index + 1
          contacts = TmpKolContact.where(:kol_uuid => params[:kol_uuid])
          present :error, 0
          present :influence_score, influence_score
          present :influence_level, Influence::Value.get_influence_level(influence_score)
          present :cal_time, Influence::Value.get_cal_time(params[:kol_uuid])
          present :joined_count, joined_contacts.size
          present :rank_index, rank_index
          present :name, TmpIdentity.get_name(params[:kol_uuid])
          present :avatar_url, TmpIdentity.get_avatar_url(params[:kol_uuid])
          present :contacts, contacts, with: API::V2::Entities::KolContactEntities::Summary
        end

        # invite
        params do
          requires :kol_uuid, type: String
          requires :mobile, type: String
        end
        post 'send_invite' do
          return error_403!({error: 1, detail: '你不能调用该接口'})      if !can_get_code?
          if  Influence::Util.is_mobile?(params[:mobile])
            invite_content = Emay::TemplateContent.get_invite_sms(TmpIdentity.get_name(params[:kol_uuid]))
            Emay::SendSms.to(params[:mobile],invite_content)
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
