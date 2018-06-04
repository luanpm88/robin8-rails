module Brand
  module V1
    class CampaignsAPI < Base
      group do
        before do
          authenticate!
          current_ability
        end

        resource :campaigns do

          # short_url api should not placed in here. but now I don't know where to placed :(
          # and should placed before :id, otherwise grape will match :id not :short_url
          desc 'Generate short url by origin url and identifier'
          params do
            requires :url, type: String
            requires :identifier, type: String
          end
          get :short_url do
            # todo: should add execption handle
            action_url_params = declared params
            uuid = Base64.encode64({ :campaign_action_url_identifier => action_url_params[:identifier], :step => '2'}.to_json).gsub("\n","")
            origin_action_url = "#{Rails.application.secrets.domain}/campaign_show?uuid=#{uuid}"
            short_url = ShortUrl.convert origin_action_url
          end

          desc "analysis link url"
          params do
            requires :url, type: String
          end
          post :analysis do
            analysis_res =  Campaign.analyze_url(params[:url])
            analysis_info = Campaign.get_analysis_info analysis_res
            present analysis_info
          end

          params do
            requires :campaign_id, type: String
          end
          get :statistics_clicks do
            campaign = Campaign.find params[:campaign_id]
            present campaign.get_stats
          end

          params do
            requires :campaign_id, type: String
          end
          get :installs do
            campaign = Campaign.find params[:campaign_id]
            present campaign.get_platforms_for_cpi
          end


          desc 'Return a campaign by id'
          params do
            requires :id, type: Integer, desc: 'Campaign id'
          end
          get ':id' do
            @campaign = Campaign.find_by(id: params[:id])

            @campaign.reset_unpay_info

            if can?(:read, @campaign)
              present @campaign
            else
              error_403! "没有查看权限"
            end
          end

          desc 'build new campaign by analysising link url'
          params do
            requires :url, type: String
            requires :per_budget_type, type: String
          end
          post 'analysis_build' do
            analysis_res = Campaign.analyze_url(params[:url])
            @campaign = Campaign.get_campaign_info(params[:url], analysis_res, params[:per_budget_type])
            present @campaign
          end

          desc 'Create a campaign'
          params do
            requires :name, type: String
            requires :description, type: String
            requires :url, type: String
            requires :img_url, type: String
            requires :budget, type: Float
            requires :per_budget_type, type: String
            requires :per_action_budget, type: Float
            optional :message, type: String
            requires :start_time, type: DateTime
            requires :deadline, type: DateTime
            requires :sub_type, type: String
            requires :example_screenshot_count, type: Integer
            requires :target, type: Hash do
              requires :age    , type:String
              requires :region , type:String
              requires :gender , type:String
              requires :tags   , type:String
            end
            optional :campaign_action_url, type: Hash do
              optional :action_url            , type: String
              optional :short_url             , type: String
              optional :action_url_identifier , type: String
            end
            requires :enable_append_push, type: String
          end
          post do
            if params[:budget].to_i < MySettings.campaign_min_budget.to_i
              error_unprocessable! "活动总预算不能低于#{MySettings.campaign_min_budget}元!"
              return
            end

            service = CreateCampaignService.new current_user, declared(params)
            Rails.logger.campaign_create.info "------user: #{current_user.id}------request_information: #{request.headers}"

            if service.perform
              present service.campaign
            else
              error_unprocessable! service.first_error_message
            end
          end

          desc 'lock budget, make budget_editable to false'
          params do
            requires :campaign_id, type: Integer
          end
          patch ":id/lock_budget" do
            @campaign = Campaign.find declared(params)[:campaign_id]
            @campaign.update_attributes(budget_editable: false)
            present @campaign
          end

          desc 'pay campaign use balance'  #使用余额支付 campaign
          params do
            requires :campaign_id, type: Integer
            requires :pay_way, type: String
            requires :use_credit, type: Boolean
          end
          patch ":id/pay_by_balance" do
            @campaign = Campaign.find declared(params)[:campaign_id]
            if declared(params)[:pay_way] == 'balance' && @campaign.status == 'unpay'

              # 积分抵扣
              used_credit, credit_amount, pay_amount = false, 0, @campaign.need_pay_amount
              if params[:use_credit]
                if current_user.credit_amount >= @campaign.need_pay_amount * 10
                  used_credit, credit_amount, pay_amount = true, @campaign.need_pay_amount * 10, 0
                else
                  used_credit, credit_amount, pay_amount = true, current_user.credit_amount, @campaign.need_pay_amount - current_user.credit_amount.to_f/10
                end
              end

              if current_user.avail_amount >= pay_amount
                if credit_amount > 0
                  Credit.gen_record('expend', 1, -credit_amount, current_user, @campaign, current_user.credit_expired_at)
                  @campaign.update_attributes(used_credit: used_credit, credit_amount: credit_amount, need_pay_amount: pay_amount, pay_way: declared(params)[:pay_way])
                else
                  @campaign.update_attributes(pay_way: declared(params)[:pay_way])
                end
                @campaign.reload
                @campaign.pay

                present @campaign
              else
                return error_unprocessable! ["amount_not_engouh", '账号余额不足, 请充值!']
              end
            else
              return error_unprocessable! "已经支付成功, 请勿重复支付!"
            end
          end

          desc 'pay campaign use alipay'  #使用支付宝支付 campaign
          params do
            requires :campaign_id, type: Integer
            requires :use_credit,  type: Boolean
          end
          post ":id/pay_by_alipay" do
            @campaign = Campaign.find declared(params)[:campaign_id]

            return error_unprocessable! "已经支付成功, 请勿重复支付!" unless @campaign.status == 'unpay'

            # 积分抵扣
            used_credit, credit_amount, pay_amount = false, 0, @campaign.need_pay_amount
            if params[:use_credit]
              if current_user.credit_amount >= @campaign.need_pay_amount * 10
                used_credit, credit_amount, pay_amount = true, @campaign.need_pay_amount * 10, 0
              else
                used_credit, credit_amount, pay_amount = true, current_user.credit_amount, @campaign.need_pay_amount - current_user.credit_amount.to_f/10
              end
            end

            @campaign.update_attributes(
              used_credit:      used_credit, 
              credit_amount:    credit_amount, 
              need_pay_amount:  pay_amount, 
              pay_way:          'alipay'
            )

            if pay_amount > 0

              ALIPAY_RSA_PRIVATE_KEY = Rails.application.secrets[:alipay][:private_key]
              return_url = Rails.env.development? ? 'http://acacac.ngrok.cc/brand?from=pay_campaign' : "#{Rails.application.secrets[:domain]}/brand?from=pay_campaign"
              notify_url = Rails.env.development? ? 'http://acacac.ngrok.cc/brand_api/v1/campaigns/alipay_notify' : "#{Rails.application.secrets[:domain]}/brand_api/v1/campaigns/alipay_notify"

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
              Credit.gen_record('expend', 1, -credit_amount, current_user, @campaign, current_user.credit_expired_at)
              @campaign.update_attributes(status: 'unexecute')
              @campaign.reload

              present @campaign
            end
          end

          desc 'revoke campaign'  #撤销 campaign
          params do
            requires :campaign_id, type: Integer
          end
          patch ":id/revoke_campaign" do
            @campaign = Campaign.find declared(params)[:campaign_id]
            if @campaign.status == "revoked"
              error_unprocessable! "活动已经撤销, 不能重复撤销!" and return
            end
            unless %w(unpay unexecute rejected).include? @campaign.status
              error_unprocessable! "活动已经开始, 不能撤销!" and return
            end
            @campaign.revoke
            present @campaign
          end

          desc 'Update a campaign'
          params do
            requires :name, type: String
            requires :description, type: String
            requires :url, type: String
            requires :img_url, type: String
            requires :budget, type: Float
            requires :per_budget_type, type: String
            requires :per_action_budget, type: Float
            optional :message, type: String
            requires :start_time, type: DateTime
            requires :deadline, type: DateTime
            requires :sub_type, type: String
            requires :example_screenshot_count, type: Integer
            requires :target, type: Hash do
              requires :age    , type:String
              requires :region , type:String
              requires :gender , type:String
              requires :tags   , type:String
            end
            optional :campaign_action_url, type: Hash do
              optional :action_url            , type: String
              optional :short_url             , type: String
              optional :action_url_identifier , type: String
            end
            requires :enable_append_push, type: String
          end
          put ':id' do
            if params[:budget].to_i < MySettings.campaign_min_budget.to_i
              error_unprocessable! "总预算不能低于#{MySettings.campaign_min_budget}元!"
            end
            service = UpdateCampaignService.new current_user, params[:id], declared(params)

            if service.perform
              present service.campaign
            else
              error_unprocessable! service.first_error_message
            end
          end

          desc 'Update a campaign base info'
          params do
            requires :name, type: String
            requires :description, type: String
            requires :url, type: String
            requires :img_url, type: String
          end
          put ':id/edit_base' do
            error_403! unless  is_super_user?
            campaign = Campaign.find params[:id]
            campaign.update_columns({name: params[:name], description: params[:description], url: params[:url], img_url: params[:img_url]})
            present campaign
          end


          desc 'evaluate  campaign  info'
          params do
            requires :review_content, type: String
            requires :effect_score, type: Integer
          end
          put ':id/evaluate' do
            @campaign = Campaign.find params[:id]
            if @campaign.evaluation_status != "evaluating"
              error_unprocessable! "该活动你已评价,或暂时不能评价!" and return
            end
            CampaignEvaluation.evaluate(@campaign, params[:effect_score], params[:experience_score], params[:review_content])
            present @campaign
          end
        end

        desc 'Create a recruit campaign'
        params do
          requires :name, type: String
          requires :description, type: String
          requires :img_url, type: String
          requires :recruit_start_time, type: DateTime
          requires :recruit_end_time, type: DateTime
          requires :start_time, type: DateTime
          requires :deadline, type: DateTime
          requires :per_action_budget, type: Float
          requires :recruit_person_count, type: Float
          optional :budget,   type: Float
          optional :age, type:String
          optional :gender, type:String
          optional :region, type: String
          optional :sns_platforms, type: String
          optional :tags, type: String
          optional :hide_brand_name, type: Boolean
          optional :material_ids, type: String
          optional :url, type: String, default: nil
          optional :sub_type, type: String
        end
        post 'recruit_campaigns' do
          params[:budget] = params[:recruit_person_count] * params[:per_action_budget]
          if params[:budget].to_i < MySettings.campaign_min_budget.to_i
            error_unprocessable! "总预算不能低于#{MySettings.campaign_min_budget}元!"
          end
          service = CreateRecruitCampaignService.new current_user, declared(params)
          if service.perform
            present service.campaign
          else
            error_unprocessable! service.first_error_message
          end
        end

        desc 'Update a recruit campaign'
        params do
          requires :name, type: String
          requires :description, type: String
          requires :img_url, type: String
          requires :recruit_start_time, type: DateTime
          requires :recruit_end_time, type: DateTime
          requires :start_time, type: DateTime
          requires :deadline, type: DateTime
          requires :per_action_budget, type: Float
          requires :recruit_person_count, type: Float
          optional :budget,   type: Float
          optional :age, type:String
          optional :gender, type:String
          optional :region, type: String
          optional :sns_platforms, type: String
          optional :tags, type: String
          optional :hide_brand_name, type: Boolean
          optional :material_ids, type: String, default: nil
          optional :url, type: String
          optional :sub_type, type: String
        end
        put '/recruit_campaigns/:id' do
          params[:budget] = params[:recruit_person_count] * params[:per_action_budget]
          if params[:budget].to_i < MySettings.campaign_min_budget.to_i
            error_unprocessable! "总预算不能低于#{MySettings.campaign_min_budget}元!"
          end
          service = UpdateRecruitCampaignService.new current_user, params[:id], declared(params)
          if service.perform
            present service.campaign
          else
            error_unprocessable! service.first_error_message
          end
        end

        desc "Get a recruit_campaign"
        params do
          requires :id, type: Integer
        end
        get '/recruit_campaigns/:id' do
          @recruit_campaign = Campaign.find_by(id: declared(params)[:id])
          if can?(:read, @recruit_campaign)
            present @recruit_campaign
          else
            error_403! "没有查看权限"
          end
        end

        desc "change recruit_campaign's 'end_apply_check' status "
        params do
          requires :id, type: Integer
        end
        put "/recruit_campaigns/:id/end_apply_check" do
          CampaignApply.end_apply_check(declared(params)[:id])
          present Campaign.find_by(id: declared(params)[:id])
        end

        resource :invite_campaigns do
          desc 'Create a invite campaign'
          params do
            requires :name, type: String
            requires :description, type: String
            requires :img_url, type: String
            # requires :budget, type: Float
            requires :start_time, type: DateTime
            requires :deadline, type: DateTime
            requires :social_accounts, type: String
            optional :material_ids, type: String
          end
          post "/" do
            service = CreateInviteCampaignService.new current_user, declared(params)

            if service.perform
              present service.campaign
            else
              error_unprocessable! service.first_error_message
            end
          end

          desc 'Update a invite campaign'
          params do
            requires :name, type: String
            requires :description, type: String
            requires :img_url, type: String
            # optional :budget,   type: Float
            requires :start_time, type: DateTime
            requires :deadline, type: DateTime
            requires :social_accounts, type: String
            optional :material_ids, type: String
          end
          put '/:id' do
            service = UpdateInviteCampaignService.new current_user, params[:id], declared(params)
            if service.perform
              present service.campaign
            else
              error_unprocessable! service.first_error_message
            end
          end

          desc "Get a invite campaign"
          params do
            requires :id, type: Integer
          end
          get '/:id' do
            @invite_campaign = Campaign.find_by(id: declared(params)[:id])
            if can?(:read, @invite_campaign)
              present @invite_campaign
            else
              error_403! "没有查看权限"
            end
          end

          desc "获取特约活动的campaign_invites"
          params do
            requires :id, type: Integer
          end
          get '/:id/agreed_invites' do
            @invite_campaign = Campaign.find_by(id: declared(params)[:id])
            present @invite_campaign.campaign_invites.verifying_or_approved
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
            return error_unprocessable! "支付失败，请重试"
          end
        end
      end

    end
  end
end
