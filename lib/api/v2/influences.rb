module API
  module V2
    class Influences < Grape::API
      resources :influences do
        #第三方账号 价值
        params do
          requires :provider, type: String, values: ['weibo', 'wechat']
          requires :uid, type: String
          requires :token, type: String
          requires :name, type: String
          requires :serial_params, type: String
          optional :url, type: String
          optional :avatar_url, type: String
          optional :desc, type: String
          optional :followers_count, Integer
          optional :statuses_count, Integer
          optional :registered_at, DateTime
          optional :verified, :boolean
          optional :refresh_token, :string
          optional :kol_uuid, :string
          optional :unionid, type: String
        end
        post 'bind_identity' do
          if params[:provider] == 'weibo'
            required_attributes! [:followers_count, :statuses_count, :registered_at, :verified, :refresh_token]
          else
            required_attributes! [:unionid]
          end
          kol_uuid = params[:kol_uuid].blank? ? SecureRandom.hex : params[:kol_uuid]
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
          requires :kol_uuid, :string
        end
        post 'unbind_identity' do
          kol_identities = TmpIdentity.get_identities(kol_uuid)
          if kol_identities.collect{|identity| identity.uid }.include? params[:uid]
            present :error, 1
            present :detail, "删除的账号不存在"
          else
            TmpIdentity.find_by(:kol_uuid => kol_uuid, :uid => params[:uid]).delete
            present :error, 0
          end
          present :kol_uuid, kol_uuid
          present :kol_identities, kol_identities, with: API::V1::Entities::IdentityEntities::Summary
        end


        #联系人
        params do
          requires :contacts, type: String
          optional :kol_uuid, :string
        end
        post 'bind_contacts' do
          aa = params[:contacts].to_s
          contacts = JSON.parse(aa)
          return  error_403!({error: 1, detail: '联系人不存在或格式错误'})    if contacts.size == 0
          kol_uuid = params[:kol_uuid].blank? ? SecureRandom.hex : params[:kol_uuid]
          kol_contacts = TmpKolContact.add_contacts(kol_uuid,contacts)
          present :error, 0
          present :kol_uuid, kol_uuid
          # present :kol_contacts, kol_contacts
        end

        # 排名
        params do
          requires :kol_uuid, type: String
        end
        get 'rank' do
          joined_contacts = TmpKolContact.joined.where(:kol_uuid => params[:kol_uuid])
          # unjoined_contacts = TmpKolContact.unjoined.where(:kol_uuid => params[:kol_uuid]).order_by_exist
          contacts = TmpKolContact.where(:kol_uuid => params[:kol_uuid])
          present :error, 0
          present :influence_title,''
          present :joined_count, joined_contacts.size
          present :contacts, contacts, with: API::V2::Entities::KolContactEntities::Summary
        end

        # invite
        params do
          requires :kol_uuid, type: String
          requires :mobiles, type: String
        end
        post 'send_invite' do
          invite_content = YunPian::TemplateContent.get_invite_sms('','')
          mobiles = []
          params[:mobiles].split(",").each do |mobile|
            mobiles << mobile if Influence::Contact.is_mobile?(mobile)
          end
          result = YunPian::SendSms.send_msg(mobiles.join(","),invite_content)       if mobiles.size > 0
          present :error, 0
        end

        # 计算总得分
        params do
          requires :kol_uuid, type: String
        end
        post 'cal_score' do
          score = Influence::Value.get_total_score(params[:kol_uuid])    rescue 0
          @campaigns = Campaign.where(:status => 'executing')
          present :error, 0
          present :kol_uuid, params[:kol_uuid]
          present :score, score
          present :identity_hundren_score, Influence::Value.identity_score(params[:kol_uuid])
          present :contact_hundren_score, Influence::Value.contact_score(params[:kol_uuid])
          present :campaigns, @campaigns, with: API::V2::Entities::CampaignEntities::Summary
        end
      end
    end
  end
end
