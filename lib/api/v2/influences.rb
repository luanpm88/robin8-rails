module API
  module V2
    class Influences < Grape::API
      resources :influences do
        #第三方账号 价值
        params do
          requires :provider, type: String, values: ['weibo', 'wechat']
          requires :uid, type: String
          requires :token, type: String
          optional :name, type: String
          optional :url, type: String
          optional :avatar_url, type: String
          optional :desc, type: String
          optional :serial_params, type: String
          optional :followers_count, Integer
          optional :friends_count, Integer
          optional :statuses_count, Integer
          optional :registered_at, Time
          optional :verified, :boolean
          optional :refresh_token, :string
          optional :kol_uuid, :string
        end
        post 'bind_identity' do
          kol_uuid = SecureRandom.hex if params[:kol_uuid]
          kol_identities = TmpIdentity.get_identities(kol_uuid)
          if kol_identities.collect{|identity| identity.uid }.include? params[:uid]
            present :error, 1
            present :detail, "该账号已经添加"
          else
            tmp_identity = TmpIdentity.new
            attrs = attributes_for_keys [:provider, :uid, :token, :name, :url, :avatar_url, :desc, :serial_params,
                                         :followers_count, :friends_count, :statuses_count, :registered_at, :verified,
                                         :refresh_token]
            tmp_identity.from_type = 'app'
            tmp_identity.attributes = attrs
            tmp_identity.kol_uuid = kol_uuid
            tmp_identity.save
            kol_identities = TmpIdentity.get_identities(kol_uuid)
            present :error, 0
          end
          present :kol_uuid, kol_uuid
          present :kol_identities, kol_identities
        end

        #第三方账号 价值  解除绑定
        params do
          requires :provider, type: String, values: ['weibo', 'wechat']
          requires :uid, type: String
          optional :kol_uuid, :string
        end
        post 'unbind_identity' do
          kol_uuid = SecureRandom.hex if params[:kol_uuid]
          kol_identities = TmpIdentity.get_identities(kol_uuid)
          if kol_identities.collect{|identity| identity.uid }.include? params[:uid]
            present :error, 1
            present :detail, "删除的账号不存在"
          else
            TmpIdentity.find_by(:kol_uuid => kol_uuid, :uid => params[:uid]).delete
            present :error, 0
          end
          present :kol_uuid, kol_uuid
          present :kol_identities, kol_identities
        end


        #联系人
        params do
          requires :contacts, type: String
          optional :kol_uuid, :string
        end
        post 'bind_contacts' do
          contacts = JSON.parse(params[:contacts])      rescue []
          if contacts.size == 0
            return  error_403!({error: 1, detail: '联系人不存在或格式错误'})
          end
          kol_uuid = SecureRandom.hex if params[:kol_uuid]
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
          contacts = TmpIdentity.where(:kol_uuid => params[:kol_uuid]).order_by_exist
          present :error, 0
          present :kol_uuid, kol_uuid
          present :contacts, contacts, with: API::V2::Entities::KolContactEntities::Summary
        end

        # invite
        params do
          requires :kol_uuid, type: String
          requires :mobiles, type: String
        end
        post 'send_invite' do
          invite_content = YunPian::TemplateContent.get_invite_sms('','')
          result = YunPian::SendSms.send_msg(mobiles,invite_content)
          puts result
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
          present :kol_uuid, kol_uuid
          present :score, score
          present :campaigns, @campaigns, with: API::V2::Entities::CampaignEntities::Summary
        end
      end
    end
  end
end
