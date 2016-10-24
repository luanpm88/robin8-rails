module Open
  module V1
    class CampaignAPI < Base
      before do
        authenticate!
        request_limit!
      end

      resource :campaigns do

        desc 'create an campaign'
        params do
          optional :name,              type: String
          optional :description,       type: String
          requires :url,               type: String
          requires :budget,            type: Float
          requires :per_action_budget, type: Float
          requires :start_time,        type: DateTime
          requires :deadline,          type: DateTime

          requires :poster,     type: Hash
          requires :screenshot, type: Hash

          optional :age,    type: String, default: '全部'
          optional :gender, type: String, default: '全部'
          optional :region, type: String, default: '全部'
          optional :tags,   type: String, default: '全部'
        end
        post "/" do
          if params[:budget].to_f < 100
            error!({ success: false, error: '总预算不能低于100元' }, 400) and return
          end

          if (params[:start_time].to_time - Time.now) < 2.hours
            error!({ success: false, error: '活动开始时间必须是两个小时之后' }, 400) and return
          end

          if params[:deadline].to_time <= params[:start_time].to_time
            error!({ success: false, error: '结束时间需要晚于开始时间' }, 400) and return
          end

          if params[:per_action_budget] and params[:per_action_budget].to_f < 3
            error!({ success: false, error: '活动单价不能小于3元' }, 400) and return
          end

          if current_user.avail_amount < params[:budget].to_f
            error!({ success: false, error: '账户余额不够，请联系客服充值' }, 400) and return
          end

          if current_user.campaigns.where(status: %w(unpay unexecute), name: params[:name]).exists?
            error!({ success: false, error: '已经存在同名的未开始的活动' }, 400) and return
          end

          if params[:tags] and params[:tags] != "全部"
            params[:tags] = Tag.where(label: params[:tags].split(",")).map(&:label).join(",")
            params[:tags] = "全部" unless params[:tags].present?
          end

          if params[:gender] and params[:gender] != "全部"
            params[:gender] = ([1, 2].include? params[:gender].to_i) ? params[:gender] : "全部"
          end

          if params[:age] and params[:age] != "全部"
            min, max = params[:age].split(',').map(&:to_i)
            params[:age] = min < max ? [min, max].join(',') : "全部"
          end

          if params[:region] and params[:region] != "全部"
            cities = params[:region].split(',').collect { |name| City.where("name like '#{name}%'").take }
            params[:region] = cities.present? ? cities.map(&:name).join(',') : "全部"
          end

          declared_params = declared(params)

          if params[:poster]
            poster = AvatarUploader.new
            poster.store!(params[:poster])
            declared_params.merge!(:img_url => poster.url)
          end

          if params[:screenshot]
            screenshot = AvatarUploader.new
            screenshot.store!(params[:screenshot])
            declared_params.merge!(:example_screenshot => screenshot)
          end

          declared_params.reverse_merge!({
            :name => "新的开放接口创建的CPI活动",
            :description => "无",
            :per_budget_type => "simple_cpi",
            :img_url => "-",
            :need_pay_amount => params[:budget],
            :campaign_from => "open"
          })

          service = KolCreateCampaignService.new(current_user, declared_params)

          if service.perform and service.errors.empty?
            @campaign = service.campaign
            @campaign.update!(
              pay_way:        'balance',
              budget_editable: false
            )
            @campaign.pay

            present :success,      true
            present :avail_amount, current_user.avail_amount.to_f
            present :campaign,     @campaign, with: Open::V1::Entities::Campaign::CampaignDetail
          else
            error!({ success: false, error: service.first_error_message }, 400) and return
          end
        end

        desc "update existed campaign"
        params do
          requires :id,                type: Integer
          optional :name,              type: String
          optional :description,       type: String
          optional :url,               type: String
          optional :per_action_budget, type: Float
          optional :start_time,        type: DateTime
          optional :deadline,          type: DateTime
          # optional :budget,            type: Float

          optional :poster,     type: Hash
          optional :screenshot, type: Hash

          optional :age,    type: String, default: '全部'
          optional :gender, type: String, default: '全部'
          optional :region, type: String, default: '全部'
          optional :tags,   type: String, default: '全部'
        end
        put '/:id' do
          @campaign = Campaign.find params[:id]

          unless %w(unexecute rejected).include?(@campaign.status)
            error!({success: false, error: "活动已经开始不能修改!"}) and return
          end

          # if params[:budget] and params[:budget].to_f < 100
          #   error!({success: false, error: "总预算不能低于100元!"}) and return
          # end

          if params[:start_time] and (params[:start_time].to_time - Time.now) < 2.hours
            error!({success: false, error: "活动开始时间必须是两个小时之后!"}) and return
          end

          if params[:deadline] and params[:deadline].to_time <= params[:start_time].to_time
            error!({success: false, error: "结束时间需要晚于开始时间!"}) and return
          end

          if params[:per_action_budget] and params[:per_action_budget].to_f < 3
            error!({ success: false, error: '活动单价不能小于3元' }, 400) and return
          end

          if params[:tags] and params[:tags] != "全部"
            params[:tags] = Tag.where(label: params[:tags].split(",")).map(&:label).join(",")
            params[:tags] = "全部" unless params[:tags].present?
          end

          if params[:gender] and params[:gender] != "全部"
            params[:gender] = ([1, 2].include? params[:gender].to_i) ? params[:gender] : "全部"
          end

          if params[:age] and params[:age] != "全部"
            min, max = params[:age].split(',').map(&:to_i)
            params[:age] = min < max ? [min, max].join(',') : "全部"
          end

          if params[:region] and params[:region] != "全部"
            cities = params[:region].split(',').collect { |name| City.where("name like '#{name}%'").take }
            params[:region] = cities.present? ? cities.map(&:name).join(',') : "全部"
          end

          # fix required params bug
          declared_params = declared(params).compact.reverse_merge({
            url: @campaign.url,
            name: @campaign.name,
            per_action_budget: @campaign.per_action_budget
          })

          if params[:poster]
            poster = AvatarUploader.new
            poster.store!(params[:poster])
            declared_params.merge!(:img_url => poster.url)
          end

          if params[:screenshot]
            screenshot = AvatarUploader.new
            screenshot.store!(params[:screenshot])
            declared_params.merge!(:example_screenshot => screenshot)
          end

          if @campaign.status == "rejected"
            @campaign.status = "unexecute"
            @campaign.invalid_reasons = nil
          end

          declared_params.reject! {|i| [:id].include? i}.to_h

          service = KolUpdateCampaignService.new(current_user, @campaign, declared_params)
          if service.perform and service.errors.empty?
            present :success,      true
            present :avail_amount, current_user.avail_amount.to_f
            present :campaign,     @campaign, with: Open::V1::Entities::Campaign::CampaignDetail
          else
            error!({ success: false, error: service.first_error_message }, 400) and return
          end
        end

        desc "revoke campaign"
        params do
          requires :id, type: Integer
        end
        delete "/:id/revoke" do
          @campaign = current_user.campaigns.find(params[:id])

          if @campaign.status == "revoked"
            error!({ success: false, error: '活动已经撤销,不能重复撤销!' }, 400) and return
          end

          if %w(unpay unexecute rejected).exclude? @campaign.status
            error!({success: false, error: "活动已经通过审核,不能撤销!"}, 400) and return
          end

          if @campaign.revoke
            present :success, true
            present :msg, "活动撤销成功!"
          else
            error!({success: false, error: "活动撤销失败,发生异常!"}, 400) and return
          end
        end

        desc "get all campaign of current user"
        params do
          optional :campaign_type, type: String
          optional :page,   type: Integer
        end
        get "/" do
          @campaigns = current_user.campaigns

          case params[:campaign_type]
          when 'unpay'
            @campaigns = @campaigns.where(:status => 'unpay')
          when 'checking'
            @campaigns = @campaigns.where(:status => ['unexecute', "rejected"])
          when 'running'
            @campaigns = @campaigns.where(:status => ['agreed', "executing"])
          when 'completed'
            @campaigns = @campaigns.where(:status => ['executed', "settled"])
          end

          @campaigns = @campaigns.order("created_at DESC").page(params[:page]).per_page(10)

          present :success, true
          present :campaigns,    @campaigns, with: Open::V1::Entities::Campaign::CampaignList
          present :total_count,  @campaigns.count
          present :current_page, @campaigns.current_page
          present :total_pages,  @campaigns.total_pages
        end


        desc "get campaign detail by id"
        params do
          requires :id, type: Integer
        end
        get "/:id" do
          @campaign = current_user.campaigns.find(params[:id])

          present :success,  true
          present :campaign, @campaign, with: Open::V1::Entities::Campaign::CampaignDetail
        end

        desc "get joined kol invites of campaign"
        params do
          requires :id, type: Integer
        end
        get "/:id/invites" do
          @campaign = current_user.campaigns.find(params[:id])
          @invites  = @campaign.valid_invites({:include => :kol }).page(params[:page]).per_page(20)

          present :success, true
          present :invites, @invites, with: Open::V1::Entities::Campaign::CampaignInviteList
          present :total_count,  @invites.count
          present :current_page, @invites.current_page
          present :total_pages,  @invites.total_pages
        end
      end
    end
  end
end