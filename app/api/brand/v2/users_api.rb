module Brand
  module V2
    class UsersAPI < Base
      include Grape::Kaminari

      group do
        before do
          authenticate!
        end

        resource :users do
          desc 'collect kols' #添加收藏
          params do
            requires :profile_id,     type: String #plateform_uuid, uuid
            requires :profile_name,   type: String #name 用户名称
            requires :avatar_url,     type: String #用户的头像地址
            requires :description_raw,           type: String #用户的简介 desc
            # requires :plateform_name, type: String #来自什么平台微博，微信
          end
          post 'collect_kol' do
            params[:plateform_name] = params[:profile_id].to_i.to_s == params[:profile_id] ? 'public_weibo_account' : 'public_wechat_account'

            ck = current_user.collected_kols.find_or_initialize_by(plateform_uuid: params[:profile_id])

            return {error: 1, detail: I18n.t('brand_api.errors.messages.not_repeat') } unless ck.new_record?

            ck.plateform_name = params[:plateform_name]
            ck.plateform_uuid = params[:profile_id]
            ck.name = params[:profile_name]
            ck.avatar_url = params[:avatar_url]
            ck.desc = params[:description_raw]

            if ck.save
              present current_user.collected_kols.order('created_at DESC'), with: Entities::UserCollectedKol
            else
              return {error: 1, detail: ck.errors.messages }
            end
          end

          desc 'cancel collect'
          params do
            requires :profile_id, type: String
          end
          post 'cancel_collect' do
            ck = current_user.collected_kols.find_by_plateform_uuid params[:profile_id]

            return {error: 1, detail: I18n.t('brand_api.errors.messages.not_found') } unless ck

            if ck.destroy
              present current_user.collected_kols.order('created_at DESC'), with: Entities::UserCollectedKol
            else
              return {error: 1, detail: I18n.t('brand_api.errors.messages.delete_failed') }
            end
          end

          desc 'list collect kol'
          get 'collected_kols' do
            @collected_kols = paginate(Kaminari.paginate_array(current_user.collected_kols.order('created_at DESC')))

            present @collected_kols, with: Entities::UserCollectedKol
          end


          desc 'create Competitor'
          params do
            requires :competitors, type: Array do
              requires :name,       type: String
              requires :short_name,  type: String
            end
          end

          post 'competitor' do
            params[:competitors].each do |attributes|
              current_user.competitors.find_or_create_by(name: attributes[:name], short_name: attributes[:short_name])
            end

            present current_user.competitors.order('created_at DESC'), with: Entities::Competitor
          end

          desc 'update competitor status'
          params do
            optional :status,       type: Integer
            optional :name,         type: String
            optional :short_name,   type: String
            requires :id,           type: Integer
          end
          post 'competitor/:id' do
            competitor = current_user.competitors.find_by_id params[:id]

            return {error: 1, detail: I18n.t('brand_api.errors.messages.not_found')} unless competitor

            competitor.name       = params[:name]       if params[:name]
            competitor.short_name = params[:short_name] if params[:short_name]
            competitor.status     = params[:status]     if params[:status]

            competitor.save

            present error: 0, alert: I18n.t("brand_api.success.messages.update_succeed")
          end


          desc 'create trademark'
          params do
            requires :name,         type: String
            requires :keywords,     type: String
            requires :description,  type: String
          end

          post 'trademark' do
            current_user.trademarks.where(status: 1).update_all(status: 0)
            keywords = params[:keywords].split(/[,，]/).delete_if{|ele| ele==""}.join(',')
            trademark = current_user.trademarks.find_or_initialize_by(name: params[:name], keywords: keywords, description: params[:description])
            trademark.status = 1 if trademark.valid?
            trademark.save

            present current_user.trademarks.active.order('created_at DESC'), with: Entities::Trademark
          end

          desc 'update trademark status'
          params do
            optional :status,       type: Integer
            optional :name,         type: String
            optional :keywords,     type: String
            optional :description,  type: String
            requires :id,           type: Integer
          end
          post 'trademark/:id' do
            trademark = current_user.trademarks.active.find_by_id params[:id]

            return {error: 1, detail: I18n.t("brand_api.errors.messages.not_found")} unless trademark

            current_user.trademarks.where(status: 1).update_all(status: 0) if params[:status] && params[:status].to_i == 1

            trademark.name        = params[:name]        if params[:name]
            trademark.description = params[:description] if params[:description]
            trademark.status      = params[:status]      if params[:status]

            trademark.keywords = params[:keywords].split(/[,，]/).delete_if{|ele| ele==""}.join(',') if params[:keywords]

            trademark.save

            present error: 0, alert: I18n.t('brand_api.success.messages.update_succeed')
          end

          desc 'when new brand login, update his all base info'
          params do
            requires :base_info, type: Hash do
              requires :name,          type: String
              requires :campany_name,  type: String
              optional :email,         type: String
              optional :mobile_number, type: String
            end
            requires :my_brand, type: Hash do
              requires :name,         type: String
              requires :keywords,     type: String
              optional :description,  type: String
            end
            requires :competitors, type: Array do
              requires :name,        type: String
              requires :short_name,  type: String
            end
          end
          post 'update_base_infos' do
            current_user.update_attributes(params[:base_info].compact)

            keywords = params[:my_brand][:keywords].split(/[,，]/).delete_if{|ele| ele==""}.join(',')

            trademark = current_user.trademarks.find_or_initialize_by(name: params[:my_brand][:name], keywords: keywords, description: params[:my_brand][:description])
            trademark.status = 1 if trademark.valid?
            trademark.save

            params[:competitors].each do |attributes|
              current_user.competitors.find_or_create_by(name: attributes[:name], short_name: attributes[:short_name])
            end

            present error: 0, alert: I18n.t('brand_api.success.messages.update_succeed')
          end

          desc "show current user profile"
          get '/profile' do
            present current_user, with: Entities::User
          end

          desc 'Update current user profile'
          params do
            requires :name        , type: String
            requires :real_name   , type: String
            optional :description , type: String
            # requires :keywords    , type: String
            requires :campany_name, type: String
            requires :avatar_url  ,   type: String
            optional :url         , type: String
          end
          post '/' do
            current_user.update_attributes declared(params)

            present current_user, with: Entities::User
          end


          desc 'Create a alipay for the user recharge'
          params do
            requires :credits, type: Float
          end
          post "/recharge" do
            trade_no = Time.current.strftime("%Y%m%d%H%M%S") + (1..9).to_a.sample(4).join
            credits = params[:credits].to_f

            return {error: 1, detail: I18n.t("brand_api.errors.messages.recharge_mix_amount", count: MySettings.recharge_min_budget) } if MySettings.recharge_min_budget > credits

            invite_code = params[:invite_code]
            ALIPAY_RSA_PRIVATE_KEY = Rails.application.secrets[:alipay][:private_key]
            return_url = Rails.env.development? ? 'http://aabbcc.ngrok.cc/brand' : "#{Rails.application.secrets[:vue_brand_domain]}"
            notify_url = Rails.env.development? ? 'http://aabbcc.ngrok.cc/brand_api/v2/users/alipay_notify' : "#{Rails.application.secrets[:domain]}/brand_api/v2/users/alipay_notify"

            # 账户充值页面 (/brand/financial/recharge) 不再提供开具发票选项，
            # 所以 need_invoice 为 false，tax 为零
            @alipay_order =  current_user.alipay_orders.build({trade_no: trade_no, credits: credits, tax: 0, need_invoice: false, invite_code: invite_code})
            if @alipay_order.save
              alipay_recharge_url = Alipay::Service.create_direct_pay_by_user_url(
                                      { out_trade_no: trade_no,
                                        subject: 'Robin8账户充值',
                                        total_fee: (ENV["total_fee"] || credits).to_f,
                                        return_url: return_url,
                                        notify_url: notify_url
                                      },
                                      {
                                        sign_type: 'RSA',
                                        key: ALIPAY_RSA_PRIVATE_KEY
                                      }
                                    )
              return { alipay_recharge_url: alipay_recharge_url }
            else
              return {error: 1, detail: @alipay_order.errors.messages.first.last.first }
            end
          end

          post "/onepay/recharge" do
            trade_no = Time.current.strftime("%Y%m%d%H%M%S") + (1..9).to_a.sample(4).join
            credits = (params[:credits].to_f * 100).to_i

            puts Rails.application.secrets[:onepay]

            secret = Rails.application.secrets[:onepay][params[:onepay_type].to_sym]

            return {error: 1, detail: I18n.t("brand_api.errors.messages.recharge_mix_amount", count: MySettings.recharge_min_budget) } if MySettings.recharge_min_budget > credits

            invite_code = params[:invite_code]
            vpc_Merchant = secret[:vpc_Merchant]
            return_url = "#{Rails.application.secrets[:vue_brand_domain]}"
            notify_url = "#{Rails.application.secrets[:domain]}/brand_api/v2/users/onepay_notify/#{params[:onepay_type]}"



            # 账户充值页面 (/brand/financial/recharge) 不再提供开具发票选项，
            # 所以 need_invoice 为 false，tax 为零
            @alipay_order =  current_user.alipay_orders.build({trade_no: trade_no, credits: credits, tax: 0, need_invoice: false, invite_code: invite_code})
            if @alipay_order.save
              data = []
              data << "vpc_AccessCode=" + secret[:vpc_AccessCode]
              data << "vpc_Amount=" + credits.to_s
              data << "vpc_Command=pay"
              data << "vpc_Locale=vn"
              data << "vpc_MerchTxnRef=" + trade_no
              data << "vpc_Merchant=" + secret[:vpc_Merchant]
              data << "vpc_OrderInfo=Robin8_Recharge"
              data << "vpc_ReturnURL=" + notify_url
              data << "vpc_TicketNo=" + env['REMOTE_ADDR']
              data << "vpc_Version=2"

              # OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, data)
              vpc_SecureHash = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), [secret[:hash_key]].pack('H*'), data.join('&')).upcase

              dataUrl = data
              dataUrl << "AgainLink=" + secret[:vpc_Merchant]
              dataUrl << "Title=" + secret[:vpc_Merchant]
              dataUrl << "vpc_SecureHash=" + vpc_SecureHash

              onepay_recharge_url = secret[:endpoint] + '?' + dataUrl.join('&')

              return { onepay_recharge_url: onepay_recharge_url }
            else
              return {error: 1, detail: @alipay_order.errors.messages.first.last.first }
            end
          end
        end
      end


      group do
        post 'users/alipay_notify' do
          params.delete 'route_info'
          if Alipay::Sign.verify?(params) && Alipay::Notify.verify?(params)
            @alipay_order = AlipayOrder.find_by trade_no: params[:out_trade_no]
            if params[:trade_status] == 'TRADE_SUCCESS'
              @alipay_order.with_lock do
                @alipay_order.pay
                @alipay_order.save_tax_to_transaction
              end
            end
            @alipay_order.save_alipay_trade_no(params[:trade_no])
            @alipay_order.save_trade_no_to_transaction(params[:out_trade_no])
            # 送积分{_method, score, owner, resource, expired_at, remark}
            if (pr = Promotion.valid) && pr.min_credit <= @alipay_order.credits
              Credit.gen_record(
                'recharge',
                1,
                (@alipay_order.credits * pr.rate).to_i,
                @alipay_order.user,
                @alipay_order,
                pr.valid_days_count.days.since,
                "充#{@alipay_order.credits}元, 赠送#{(@alipay_order.credits * pr.rate).to_i}积分"
              )
            end
            env['api.format'] = :txt
            body "success"
          else
            return {error: 1, detail: I18n.t('brand_api.errors.messages.recharge_failed') }
          end
        end
      end

      group do
        get 'users/onepay_notify/:onepay_type' do
          secret = Rails.application.secrets[:onepay][params[:onepay_type].to_sym]
          secure_hash = params[:vpc_SecureHash]

          data = []
          allParams = params.to_h.sort
          allParams.each do |item|
            key = item[0]
            value = item[1]
            if key != "vpc_SecureHash" && value.to_s.length > 0 && ((key[0,4] == "vpc_") || (key[0,4] =="user_"))
              data << "#{key}=#{value}"
            end
          end

          hash = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), [secret[:hash_key]].pack('H*'), data.join('&')).upcase

          params.delete 'route_info'
          if secure_hash == hash && params[:vpc_TxnResponseCode] == '0'
            @alipay_order = AlipayOrder.find_by trade_no: params[:vpc_MerchTxnRef]
            if true
              @alipay_order.with_lock do
                @alipay_order.pay
                @alipay_order.save_tax_to_transaction
              end
            end
            @alipay_order.save_alipay_trade_no(params[:vpc_MerchTxnRef])
            @alipay_order.save_trade_no_to_transaction(params[:vpc_MerchTxnRef])
            # 送积分{_method, score, owner, resource, expired_at, remark}
            if (pr = Promotion.valid) && pr.min_credit <= @alipay_order.credits
              Credit.gen_record(
                'recharge',
                1,
                (@alipay_order.credits * pr.rate).to_i,
                @alipay_order.user,
                @alipay_order,
                pr.valid_days_count.days.since,
                "Thanh toán #{@alipay_order.credits}₫, Nhận được #{(@alipay_order.credits * pr.rate).to_i} điểm"
              )
            end
            env['api.format'] = :txt
            return_url = "#{Rails.application.secrets[:vue_brand_domain]}/wallet/recharge"
            body "<script>window.location='#{return_url}'</script>"
        else
            sErrors = {
              "0": "Transaction was successful",
              "?": "Transaction status was unknown",
              "1": "Bank system reject",
              "2": "Bank Declined Transaction",
              "3": "No Reply from Bank",
              "4": "Expired Card",
              "5": "Insufficient funds",
              "6": "Error Communicating with Bank",
              "7": "Payment Server System Error",
              "8": "Transaction Type Not Supported",
              "9": "Bank declined transaction (Do not contact Bank)",
              "A": "Transaction Aborted",
              "B": "Transaction was failed. It cannot authenticated by 3D-Secure Program. Please contact the Issuer Bank for support.",
              "C": "Transaction Cancelled",
              "D": "Deferred transaction has been received and is awaiting processing",
              "F": "Transaction was failed. 3D-Secure authentication was failed.",
              "I": "Card Security Code verification was failed.",
              "L": "Shopping Transaction Locked (Please try the transaction again later)",
              "N": "Cardholder is not enrolled in Authentication scheme",
              "P": "Transaction has been received by the Payment Adaptor and is being processed",
              "R": "Transaction was not processed - Reached limit of retry attempts allowed",
              "S": "Duplicate SessionID (OrderInfo)",
              "T": "Address Verification Failed",
              "U": "Card Security Code Failed",
              "V": "Address Verification and Card Security Code Failed",
              "99": "User Cancel",
            }

            error = sErrors[params[:vpc_TxnResponseCode].to_sym].present? ? sErrors[params[:vpc_TxnResponseCode].to_sym] : 'Unknow error!'
            return {error: 1, detail: error }
          end
        end
      end
    end
  end
end
