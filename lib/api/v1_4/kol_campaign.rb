module API
  module V1_4
    class KolCampaign < Grape::API
      resources :kol_campaigns do
        before do
          action_name =  @options[:path].join("")
          authenticate! if action_name != '/notify'
        end

        desc 'Create a campaign'
        params do
          requires :name, type: String
          requires :description, type: String
          requires :url, type: String
          requires :budget, type: Float
          requires :img, type: Hash
          requires :per_budget_type, type: String
          requires :per_action_budget, type: Float
          requires :start_time, type: DateTime
          requires :deadline, type: DateTime
        end
        post "/" do
          brand_user = current_kol.find_or_create_brand_user
          if params[:img]
            uploader = AvatarUploader.new
            uploader.store!(params[:img])
          end

          if params[:budget].to_i < 100
            error_403!({error: 1, detail: "总预算不能低于100元!"})  and return
          end

          if (params[:start_time].to_time - Time.now) < 2.hours
            error_403!({error: 1, detail: "活动开始时间必须是两个小时之后!"})  and return
          end

          if params[:deadline].to_time <= params[:start_time].to_time
            error_403!({error: 1, detail: "结束时间需要晚于开始时间!"})  and return
          end

          if params[:per_budget_type] == "click" and params[:per_action_budget] < 0.2
            error_403!({error: 1, detail: "单次点击不能低于0.2元!"})  and return
          end

          if params[:per_budget_type] == "post" and params[:per_action_budget] < 2
            error_403!({error: 1, detail: "单次转发不能低于2元!"})  and return
          end

          service = KolCreateCampaignService.new brand_user, declared(params).merge(:img_url => uploader.url, :need_pay_amount => params[:budget], :campaign_from => "app")
          service.perform
          if service.errors.empty?
            campaign = brand_user.campaigns.last
            present :error, 0
            present :campaign, campaign, with: API::V1_4::Entities::CampaignEntities::DetailEntity
            present :kol_amount, current_kol.avail_amount.to_f
          else
            error_403!({error: 1, detail: service.first_error_message})  and return
          end
        end

        desc "更新campaign"
        params do
          requires :id, type: Integer
          optional :name, type: String
          optional :description, type: String
          optional :url, type: String
          optional :img, type: Hash
          optional :img_url, type: String
          optional :per_budget_type, type: String
          optional :per_action_budget, type: Float
          optional :start_time, type: DateTime
          optional :deadline, type: DateTime
          optional :budget, type: Float
        end
        put '/update' do
          brand_user = current_kol.find_or_create_brand_user
          campaign = Campaign.find params[:id]
          unless %w(unpay unexecute rejected).include?(campaign.status)
            error_403!({error: 1, detail: "活动已经开始不能修改!"})  and return
          end
          if params[:budget].to_i < 100
            error_403!({error: 1, detail: "总预算不能低于100元!"})  and return
          end

          if (params[:start_time].to_time - Time.now) < 2.hours
            error_403!({error: 1, detail: "活动开始时间必须是两个小时之后!"})  and return
          end

          if params[:deadline].to_time <= params[:start_time].to_time
            error_403!({error: 1, detail: "结束时间需要晚于开始时间!"})  and return
          end

          if params[:per_budget_type] == "click" and params[:per_action_budget] < 0.2
            error_403!({error: 1, detail: "单次点击不能低于0.2元!"})  and return
          end
          
          if params[:per_budget_type] == "post" and params[:per_action_budget] < 2
            error_403!({error: 1, detail: "单次转发不能低于2元!"})  and return
          end
          
          declared_params = declared(params)
          if params[:img]
            uploader = AvatarUploader.new
            uploader.store!(params[:img])
            declared_params.merge!(:img_url => uploader.url)
          end

          if campaign.status == "rejected"
            declared_params.merge!(:invalid_reasons => nil, :status => 'unexecute')
          end

          declared_params.reject do |i| i == :id or i == :budget end.to_h

          unless campaign.budget_editable
            declared_params = declared_params.reject do |i| i == :budget end.to_h
          else
            if campaign.budget != params[:budget]
              campaign.need_pay_amount = params[:budget]
            end
          end

          service = KolUpdateCampaignService.new(brand_user, campaign, declared_params)
          service.perform
          campaign.reload
          present :error, 0
          present :kol_amount, current_kol.avail_amount.to_f
          present :campaign, campaign, with: API::V1_4::Entities::CampaignEntities::CampaignListEntity
        end

        desc "campaign list 列表"
        get "/" do
          brand_user = current_kol.find_or_create_brand_user
          campaigns = case params[:campaign_type]
          when 'all'
            brand_user.campaigns
          when 'unpay'
            campaigns = brand_user.campaigns.where(:status => 'unpay')
          when 'checking'
            campaigns = brand_user.campaigns.where(:status => ['unexecute', "rejected"])
          when 'running'
            campaigns = brand_user.campaigns.where(:status => ['agreed', "executing"])
          when 'completed'
            campaigns = brand_user.campaigns.where(:status => ['executed', "settled"])
          else
            campaigns = brand_user.campaigns
          end
          campaigns = campaigns.where(:per_budget_type => ["click", "post"]).order("created_at desc").page(params[:page] || 1).per_page(10)
          present :error, 0
          to_paginate(campaigns)
          present :campaigns, campaigns, with: API::V1_4::Entities::CampaignEntities::CampaignListEntity
        end

        desc "是否使用 任务奖金 抵用"
        params do
          requires :id, type: Integer
          requires :used_voucher, type: Integer
        end

        put "/pay_by_voucher" do
          brand_user = current_kol.find_or_create_brand_user
          campaign = Campaign.find params[:id]
          campaign.budget_editable = false
          if params[:used_voucher].to_i == 1 and campaign.used_voucher == false
            if current_kol.avail_amount > 0
              pay_amount = 0
              if campaign.need_pay_amount > current_kol.avail_amount
                pay_amount = current_kol.avail_amount
                current_kol.frozen pay_amount, "campaign_used_voucher", campaign
              else
                pay_amount = campaign.need_pay_amount
                current_kol.payout pay_amount, "campaign_used_voucher", campaign
              end
              campaign.need_pay_amount = campaign.need_pay_amount - pay_amount
              campaign.voucher_amount =  pay_amount
              campaign.used_voucher = true
            end
          end
          campaign.save
          campaign.reload
          present :error, 0
          present :campaign, campaign, with: API::V1_4::Entities::CampaignEntities::CampaignPayEntity
        end

        desc "获取详情" 
        params do
          requires :id, type: Integer
        end
        get "/show" do
          brand_user = current_kol.find_or_create_brand_user
          campaign = Campaign.find params[:id]
          if campaign.need_pay_amount > 0 or (campaign.need_pay_amount == 0 and params[:check_pay].to_i == 1)
            present :error, 0
            present :campaign, campaign, with: API::V1_4::Entities::CampaignEntities::CampaignPayEntity
          elsif campaign.need_pay_amount == 0 and %w(agreed executing executed settled).include? campaign.status
            present :error, 0
            present :campaign, campaign, with: API::V1_4::Entities::CampaignEntities::CampaignStatsEntity
          end
        end

        desc "获取campaign 参与人的列表"
        params do
          requires :id, type: Integer
        end
        get "/joined_kols" do
          brand_user = current_kol.find_or_create_brand_user
          campaign = Campaign.find_by :id => params[:id], :user_id => brand_user.id
          campaign_invites = paginate(Kaminari.paginate_array(campaign.valid_invites({:include => :kol })))
          present :error, 0
          present :campaign_invites, campaign_invites, with: API::V1_4::Entities::CampaignInviteEntities::JoinKolsEntity
        end

        desc '获取 全的详情'
        params do
          requires :id, type: Integer
        end
        get "/detail" do
          brand_user = current_kol.find_or_create_brand_user
          campaign = Campaign.find params[:id]
          
          present :error, 0
          if %w(unpay unexecute rejected).include? campaign.status
            present :campaign, campaign, with: API::V1_4::Entities::CampaignEntities::DetailEntity
            present :kol_amount, current_kol.avail_amount.to_f
          end
          if campaign.need_pay_amount == 0 and %w(agreed executing executed settled).include? campaign.status
            present :campaign, campaign, with: API::V1_4::Entities::CampaignEntities::CampaignStatsEntity
          end
        end

        desc "通过brand 余额 支付"
        params do
          requires :id, type: Integer
          requires :pay_way, type: String
        end

        put "/pay" do
          brand_user = current_kol.find_or_create_brand_user
          campaign = Campaign.find params[:id]
          if campaign.need_pay_amount <= 0
            error_403!({error: 1, detail: "已支付成功, 请勿重复支付"}) and return
          end
          if not %w(balance alipay).include? params[:pay_way]
            error_403!({error: 1, detail: "支付方式不正确"})  and return
          end
          if params[:pay_way] == "balance"
            if brand_user.avail_amount < campaign.need_pay_amount
              error_403!({error: 1, detail: "余额不足, 请尝试支付宝支付!!"})  and return
            else
              if campaign.campaign_from == "app"
                brand_user.payout campaign.need_pay_amount, 'campaign', campaign
                if campaign.used_voucher
                  current_kol.unfrozen campaign.voucher_amount, 'campaign_used_voucher', campaign
                  current_kol.payout campaign.voucher_amount, 'campaign_used_voucher', campaign
                end
              else
                brand_user.frozen campaign.need_pay_amount, 'campaign', campaign
              end
              campaign.need_pay_amount = 0
              campaign.pay_way = 'balance'
              campaign.save
              present :error, 0
              present :campaign, campaign, with: API::V1_4::Entities::CampaignEntities::CampaignBalancePayEntity
            end
          end

          if params[:pay_way] == "alipay"
            campaign.pay_way = "alipay"
            campaign.save
            present :error, 0
            present :campaign, campaign, with: API::V1_4::Entities::CampaignEntities::CampaignAlipayEntity
          end
        end

        desc "支付宝回调地址"
        params do
          optional :out_trade_no, type: String
          optional :discount, type: String
          optional :payment_type, type: String
          optional :subject, type: String
          optional :trade_no, type: String
          optional :buyer_email, type: String
          optional :gmt_create, type: String
          optional :notify_type, type: String
          optional :quantity, type: String
          optional :seller_id, type: String
          optional :notify_time, type: String
          optional :body, type: String
          optional :trade_status, type: String
          optional :is_total_fee_adjust, type: String
          optional :total_fee, type: String
          optional :gmt_payment, type: String
          optional :seller_email, type: String
          optional :price, type: String
          optional :buyer_id, type: String
          optional :notify_id, type: String
          optional :use_coupon, type: String
          optional :sign_type, type: String
          optional :sign, type: String
        end
        post '/notify' do
          # 走frozen 充值流程
          campaign = Campaign.find_by :trade_number =>  params[:out_trade_no]
          content_type 'text/plain'
          unless campaign.present?
            body "success" and return
          end
          if campaign.alipay_status == 1
            body "success" and return
          end
          declared_params = declared(params).reject do |i| params[i].blank?  end
          if campaign.alipay_status == 0 && Alipay::Sign.verify?(declared_params) && Alipay::Notify.verify?(declared_params)
            campaign.user.payout_by_alipay campaign.need_pay_amount, "campaign_pay_by_alipay", campaign
            campaign.need_pay_amount = 0
            campaign.alipay_status   = 1
            campaign.pay_way         = 'alipay'

            campaign.alipay_notify_text = declared(params).to_s
            campaign.save
            if campaign.used_voucher
              current_kol.unfrozen campaign.voucher_amount, 'campaign_used_voucher', campaign
              current_kol.payout campaign.voucher_amount, 'campaign_used_voucher', campaign
            end
            body "success"
            return
          end
          body "error"
        end

        desc "审核通过前 撤销"
        params do
          requires :id, type: Integer
        end
        put "/revoke" do
          brand_user = current_kol.find_or_create_brand_user
          campaign = Campaign.find params[:id]
          if campaign.status == "revoked"
            error_403!({error: 1, detail: "活动已经撤销, 不能重复撤销!"})  and return
          end
          if not %w(unpay unexecute rejected).include? campaign.status
            error_403!({error: 1, detail: "活动已经开始, 不能撤销!"})  and return
          end

          if campaign.status == "unpay"
            if campaign.used_voucher
              current_kol.unfrozen(campaign.budget-campaign.need_pay_amount, "campaign_revoke", campaign)
            end
            campaign.update(:status => "revoked", :check_time => Time.now)
          elsif %w(unexecute rejected).include? campaign.status
            if campaign.used_voucher
              current_kol.income campaign.voucher_amount, 'campaign_used_voucher_and_revoke', campaign
            end
            brand_user.income(campaign.budget-campaign.voucher_amount, "campaign_revoke", campaign)
            campaign.update(:status => "revoked", :check_time => Time.now)
          end
          present :error, 0
          present :detail, "成功撤销"
        end
      end
    end
  end
end