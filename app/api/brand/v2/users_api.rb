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
            params[:plateform_name] = params[:profile_id].to_i.to_s == params[:profile_id] ? 'weibo' : 'wechat'

            ck = current_user.collected_kols.find_or_initialize_by(plateform_uuid: params[:profile_id])

            return {error: 1, detail: "请不要重复添加" } unless ck.new_record?

            ck.plateform_name = params[:plateform_name]
            ck.plateform_uuid = params[:profile_id]
            ck.name = params[:profile_name]
            ck.avatar_url = params[:avatar_url]
            ck.desc = params[:description_raw]

            if ck.save
              present current_user.collected_kols, with: Entities::UserCollectedKol
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

            return {error: 1, detail: "数据错误，请确认" } unless ck

            if ck.destroy
              present current_user.collected_kols, with: Entities::UserCollectedKol
            else
              return {error: 1, detail: "删除失败" }
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

            present current_user.competitors, with: Entities::Competitor
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

            return {error: 1, detail: '数据错误，请确认'} unless competitor

            competitor.name       = params[:name]       if params[:name]
            competitor.short_name = params[:short_name] if params[:short_name]
            competitor.status     = params[:status]     if params[:status]
            
            competitor.save

            present error: 0, alert: '更新成功'
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

            present current_user.trademarks.active, with: Entities::Trademark
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

            return {error: 1, detail: '数据错误，请确认'} unless trademark

            current_user.trademarks.where(status: 1).update_all(status: 0) if params[:status] && params[:status].to_i == 1

            trademark.name        = params[:name]        if params[:name]
            trademark.description = params[:description] if params[:description]
            trademark.status      = params[:status]      if params[:status]

            trademark.keywords = params[:keywords].split(/[,，]/).delete_if{|ele| ele==""}.join(',') if params[:keywords]

            trademark.save

            present error: 0, alert: '更新成功'
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

            present error: 0, alert: '更新成功'
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
            return error_unprocessable! "充值最低金额为#{MySettings.recharge_min_budget}" if MySettings.recharge_min_budget > credits

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
              return error_unprocessable! @alipay_order.errors.messages.first.last.first
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
            return error_unprocessable! "充值失败，请重试"
          end
        end
      end
    end
  end
end