module Brand
  module V2
    class CampaignsAPI < Base
      include Grape::Kaminari

      group do
        before do
          authenticate!
        end
        resource :campaigns do

          desc 'pay campaign use balance'  #使用余额支付 campaign
          params do
            requires :campaign_id, type: Integer
            requires :pay_way, type: String
          end
          post "/pay_by_balance" do
            @campaign = current_user.campaigns.find_by_id declared(params)[:campaign_id]

            return {error: 1, detail: I18n.t('band_api.errors.messages.not_found')} unless @campaign

            if declared(params)[:pay_way] == 'balance' && @campaign.can_pay?
              if current_user.avail_amount >= @campaign.need_pay_amount
                @campaign.update_attributes(pay_way: declared(params)[:pay_way])
                @campaign.reload
                @campaign.pay

                present @campaign, with: Entities::Campaign
              else
                return {error: 1, detail: I18n.t('brand_api.errors.messages.account_balance_insufficient')}
              end
            else
              return {error: 1, detail: I18n.t('brand_api.errors.messages.pay_succeed')}
            end
          end

          desc 'pay campaign use alipay'  #使用支付宝支付 campaign
          params do
            requires :campaign_id, type: Integer
          end
          post "/pay_by_alipay" do
            @campaign = current_user.campaigns.find_by_id declared(params)[:campaign_id]

            return {error: 1, detail: I18n.t('brand_api.errors.messages.pay_succeed') } unless @campaign.can_pay?

            # 积分抵扣
            used_credit, credit_amount, pay_amount = false, 0, @campaign.need_pay_amount

            @campaign.update_attributes(
              used_credit:      used_credit,
              credit_amount:    credit_amount,
              need_pay_amount:  pay_amount,
              pay_way:          'alipay'
            )

            if pay_amount > 0

              ALIPAY_RSA_PRIVATE_KEY = Rails.application.secrets[:alipay][:private_key]
              return_url = Rails.env.development? ? 'http://aabbcc.ngrok.cc/brand' : "#{Rails.application.secrets[:vue_brand_domain]}"
              notify_url = Rails.env.development? ? 'http://aabbcc.ngrok.cc/brand_api/v2/campaigns/alipay_notify' : "#{Rails.application.secrets[:domain]}/brand_api/v2/campaigns/alipay_notify"

              alipay_recharge_url = Alipay::Service.create_direct_pay_by_user_url(
                {
                  out_trade_no: @campaign.trade_number,
                  subject: 'Robin8活动付款',
                  total_fee: (ENV["total_fee"] || @campaign.need_pay_amount).to_f,
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
              return { error: 1, detail: I18n.t('brand_api.errors.messages.order_pay_failed') }
            end
          end

          post "/pay_by_onepay/:onepay_type" do
            @campaign = current_user.campaigns.find_by_id params[:campaign_id]

            return {error: 1, detail: I18n.t('brand_api.errors.messages.pay_succeed') } unless @campaign.can_pay?

            # 积分抵扣
            used_credit, credit_amount, pay_amount = false, 0, @campaign.need_pay_amount

            @campaign.update_attributes(
              used_credit:      used_credit,
              credit_amount:    credit_amount,
              need_pay_amount:  pay_amount,
              pay_way:          'alipay'
            )

            if pay_amount > 0

              ALIPAY_RSA_PRIVATE_KEY = Rails.application.secrets[:alipay][:private_key]

              secret = Rails.application.secrets[:onepay][params[:onepay_type].to_sym]
              return_url = "#{Rails.application.secrets[:vue_brand_domain]}"
              notify_url = "#{Rails.application.secrets[:domain]}/brand_api/v2/campaigns/onepay_notify/#{params[:onepay_type]}"

              # amount
              amount = (ENV["total_fee"] || @campaign.need_pay_amount).to_f
              amount = (amount * 100).to_i
              trade_no = @campaign.trade_number

              onepay_recharge_url = OnepayApi.get_direct_pay_url(
                secret,
                {
                  type: params[:onepay_type],
                  amount: amount.to_s,
                  ref: Time.current.strftime("%Y%m%d%H%M%S") + (1..9).to_a.sample(4).join,
                  info: trade_no,
                  return_url: notify_url,
                  ip: env['REMOTE_ADDR']
                }
              )

              return { onepay_recharge_url: onepay_recharge_url }
            else
              return { error: 1, detail: I18n.t('brand_api.errors.messages.order_pay_failed') }
            end
          end

          desc 'revoke campaign'  #撤销 campaign
          params do
            requires :campaign_id, type: Integer
          end
          post "/revoke_campaign" do
            @campaign = current_user.campaigns.find_by_id params[:campaign_id]

            return {error: 1, detail: I18n.t('brand_api.errors.messages.not_found')} unless @campaign

            if @campaign.status == "revoked"
              return {error: 1, detail: I18n.t('brand_api.errors.messages.haved_revoke_campaign')}
            end
            unless @campaign.can_revoke?
              return {error: 1, detail: I18n.t('brand_api.errors.messages.haved_start_campaign')}
            end
            @campaign.revoke

            present @campaign, with: Entities::Campaign
          end

          params do
            requires :campaign_id, type: Integer
          end
          get "statistics_clicks" do
            campaign = Campaign.find params[:campaign_id]
            present campaign.get_stats
          end


          desc 'Get campaigns current user owns'
          get '/' do
            campaigns = paginate(Kaminari.paginate_array(current_user.campaigns.order('created_at DESC')))

            present campaigns, with: Entities::Campaign
          end

          desc "Create or Update a campaign"
          params do
            optional :id, type: Integer
            requires :name, type: String                      #活动标题
            requires :description, type: String               #活动简介
            requires :url, type: String                       #活动链接
            requires :img_url, type: String                   #活动图片
            requires :budget, type: Float                     #活动总预算
            requires :per_budget_type, type: String           #奖励模式选择(click:按照点击奖励KOL, post:按照转发奖励KOL, cpt:按照完成任务奖励KOL)
            requires :per_action_budget, type: Float          #单次预算
            optional :message, type: String                   #备注信息
            requires :start_time, type: DateTime              #活动开始时间
            requires :deadline, type: DateTime                #活动结束时间
            requires :sub_type, type: String                  #推广平台(wechat,weibo)
            requires :example_screenshot_count, type: Integer #示例图片数量
            requires :target, type: Hash do
              requires :age    , type:String
              requires :region , type:String
              requires :gender , type:String
              requires :tags   , type:String
            end
            requires :enable_append_push, type: String
          end
          post "" do
            if params[:budget].to_i < MySettings.campaign_min_budget.to_i
              return {error: 1, detail: I18n.t('brand_api.errors.messages.campaign_mix_amount', amount: MySettings.campaign_min_budget)}
            end

            if params[:id] && current_user.campaigns.find_by_id(params[:id])
              return {error: 1, detail: I18n.t('brand_api.errors.messages.campaign_not_edit')} unless current_user.campaigns.find_by_id(params[:id]).can_edit?

              service = UpdateCampaignService.new current_user, params[:id], declared(params)
            else
              service = CreateCampaignService.new current_user, declared(params)
              Rails.logger.campaign_create.info "------user: #{current_user.id}------request_information: #{request.headers}"
            end

            if service.perform
              present service.campaign, with: Entities::Campaign
            else
              error_unprocessable! service.first_error_message
            end
          end

          #详情
          desc "show a campaign"
          params do
          end
          get "/:id" do
            campaign = current_user.campaigns.find_by_id params[:id]

            return {error: 1, detail: I18n.t('brand_api.errors.messages.not_found')} unless campaign

            present campaign, with: Entities::Campaign
          end

          #评价
          desc 'evaluate  campaign  info'
          params do
            requires :campaign_id, type: Integer
            requires :review_content, type: String
            requires :effect_score, type: Integer
          end
          post 'evaluate' do
            @campaign = Campaign.find params[:campaign_id]

            return {error: 1, detail: I18n.t('brand_api.errors.messages.campaign_not_evaluate')} unless @campaign.can_evaluate?

            if @campaign.evaluation_status != "evaluating"
              return {error: 1, detail: I18n.t('brand_api.errors.messages.campaign_have_evaluate')}
            end
            CampaignEvaluation.evaluate(@campaign, params[:effect_score], params[:experience_score], params[:review_content])

            present @campaign, with: Entities::Campaign
          end


        end
      end


      group do
        post 'campaigns/alipay_notify' do
          params.delete 'route_info'
          Rails.logger.alipay.info "-------- web端单笔支付，进入'campaigns/alipay_notify'路由  --------------"
          if Alipay::Sign.verify?(params) && Alipay::Notify.verify?(params) && params[:trade_status] == 'TRADE_SUCCESS'
            Rails.logger.alipay.info "-------- web端单笔支付，验证 支付宝签名 成功  --------------"
            @campaign = Campaign.find_by trade_number: params[:out_trade_no]
            Rails.logger.alipay.info "-------- web端单笔支付，查找 @campaign 成功,  --- campaign_id: #{@campaign.id}---  ---campaign_name: #{@campaign.name}--- ---campaign_budget: #{@campaign.budget} ---need_pay_amount: #{@campaign.need_pay_amount}付款成功  --------------"
            if @campaign.alipay_status == 0
              @campaign.with_lock do
                @campaign.update_attributes!(alipay_notify_text: params.to_s, pay_way: 'alipay')
                @campaign.pay
                # 支付成功，扣除积分
                Credit.gen_record('expend', 1, -@campaign.credit_amount, @campaign.user, campaign, @campaign.user.credit_expired_at,
                  '支付宝抵扣 活动 #{campaign.id}') if @campaign.used_credit && @campaign.credit_amount > 0
              end
            end
            Rails.logger.alipay.info "-------- web端单笔支付, --- campaign_id: #{@campaign.id}---  ---campaign_name: #{@campaign.name}--- ---campaign_budget: #{@campaign.budget} --- need_pay_amount: #{@campaign.need_pay_amount}付款成功  --------------"
            env['api.format'] = :txt
            body "success"
          else
            return {error: 1, detail: I18n.t('brand_api.errors.messages.order_pay_failed')}
          end
        end

        get 'campaigns/onepay_notify/:onepay_type' do
          params.delete 'route_info'
          Rails.logger.alipay.info "-------- web端单笔支付，进入'campaigns/onepay_notify/#{params[:onepay_type]}'路由  --------------"

          secret = Rails.application.secrets[:onepay][params[:onepay_type].to_sym]
          request_valid = OnepayApi.check_valid_request(secret, params)

          if request_valid && params[:vpc_TxnResponseCode] == '0'
            Rails.logger.alipay.info "-------- web端单笔支付，验证 支付宝签名 成功  --------------"
            @campaign = Campaign.find_by trade_number: params[:vpc_OrderInfo]
            Rails.logger.alipay.info "-------- web端单笔支付，查找 @campaign 成功,  --- campaign_id: #{@campaign.id}---  ---campaign_name: #{@campaign.name}--- ---campaign_budget: #{@campaign.budget} ---need_pay_amount: #{@campaign.need_pay_amount}付款成功  --------------"
            if @campaign.alipay_status == 0
              @campaign.with_lock do
                @campaign.update_attributes!(alipay_notify_text: params.to_s, pay_way: 'alipay')
                @campaign.pay
                # 支付成功，扣除积分
                Credit.gen_record('expend', 1, -@campaign.credit_amount, @campaign.user, campaign, @campaign.user.credit_expired_at,
                  '支付宝抵扣 活动 #{campaign.id}') if @campaign.used_credit && @campaign.credit_amount > 0
              end
            end
            Rails.logger.alipay.info "-------- web端单笔支付, --- campaign_id: #{@campaign.id}---  ---campaign_name: #{@campaign.name}--- ---campaign_budget: #{@campaign.budget} --- need_pay_amount: #{@campaign.need_pay_amount}付款成功  --------------"
            env['api.format'] = :txt

            return_url = "#{Rails.application.secrets[:vue_brand_domain]}/campaigns/#{@campaign.id}"
            body "<script>window.location='#{return_url}'</script>"
          else
            return {error: 1, detail: I18n.t('brand_api.errors.messages.order_pay_failed')}
          end
        end
      end
    end
  end
end
