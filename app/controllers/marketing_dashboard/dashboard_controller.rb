class MarketingDashboard::DashboardController < MarketingDashboard::BaseController

  def index
    #如果代码中新增$redis.get("r8_daily_info")的key, 需要删除原有的$redis.del("r8_daily_info")从新进行赋值
    
    @r8_infos = $redis.get("r8_daily_info")
    @ending   = Time.now.change({ hour: 19 })
    # @r8_infos = nil
    if @r8_infos
      @r8_infos = JSON @r8_infos
    else
      @r8_infos = {}
      
      @r8_infos['first_overall'] = {
        'today_kols_count':           Kol.where("created_at > ?", Date.today.to_time).from_app.count,
        'pending_campaigns_count':    Campaign.where(status: 'unexecute').realable.where("deadline >?", (Time.now-30.days)).count,
        'pending_screenshots_count':  CampaignInvite.where(img_status: :pending).where("screenshot is not NULL").count,
        'pending_tixians_count':      Withdraw.pending.count
      }

      _ary = Campaign.find_by_sql("select count(*) as c_count, sum(campaigns.budget)as c_budget from campaigns where status='settled'")

      @r8_infos['table'] = {
        'users_count':              User.count,
        'traded_users_count':       User.joins(:campaigns).group("campaigns.user_id").having("count(campaigns.id) > 0").count.keys.count,
        'kols_count':               Kol.from_app.count,
        # 'active_kols_count':        Kol.joins(:campaign_invites).where("campaign_invites.status ='settled'").group("campaign_invites.kol_id").having("count(campaign_invites.id) > 0").count.keys.count,
        # 活越用户，近6个月登录过
        'active_kols_count':        Kol.where('current_sign_in_at > ?', 6.months.ago).count,
        'settled_campaigns_count':  _ary.first.c_count,
        'settled_campaigns_amount': _ary.first.c_budget.to_f,
        'withdrawn_total_amount':   Withdraw.approved.sum(:credits).round
      }


      @r8_infos['kol'] = {
        'register_count': Kol.recent(@ending - 1.day, @ending).from_app.count,
        'dua':   Kol.dua.count
      }

      @r8_infos['weibo']  = {
        'today_total':  WeiboAccount.recent(@ending - 1.day, @ending).count,
        'pending':      WeiboAccount.by_status(0).count, 
        'passed':       WeiboAccount.by_status(1).count, 
        'rejected':     WeiboAccount.by_status(-1).count
      }

      @r8_infos['wechat'] = {
        'today_total':  PublicWechatAccount.recent(@ending - 1.day, @ending).count,
        'pending':      PublicWechatAccount.by_status(0).count, 
        'passed':       PublicWechatAccount.by_status(1).count, 
        'rejected':     PublicWechatAccount.by_status(-1).count
      }
      # pry.binding
      @r8_infos['big_v_count'] = @r8_infos['weibo'][:today_total] + @r8_infos['wechat'][:today_total]

      @r8_infos['creator'] = {
        'today_total':  Creator.recent(@ending - 1.day, @ending).count,
        'pending':      Creator.by_status(0).count, 
        'passed':       Creator.by_status(1).count, 
        'rejected':     Creator.by_status(-1).count
      }

      @r8_infos['user'] = {
        'register_count': User.recent(@ending - 1.day, @ending).count
      }

      c = Campaign.where("start_time > ? and start_time < ?", @ending - 1.day, @ending).where(status: ['settled', 'executing', 'executed'])
      c_7days = Campaign.where("start_time > ? and start_time < ?", @ending - 7.day, @ending).where(status: ['settled', 'executing', 'executed'])
      c_30days = Campaign.where("start_time > ? and start_time < ?", @ending - 30.day, @ending).where(status: ['settled', 'executing', 'executed'])

      @r8_infos['campaign'] = {
        'created_count': c.count,
        'total_budget':  c.sum(:budget).round(2),
        'total_revenue': (c.sum(:budget) * 0.4).round(2),
        'top_3' =>       []
      }

      @r8_infos['campaign_7days'] = {
        'created_count': c_7days.count,
        'total_budget':  c_7days.sum(:budget).round(2),
        'total_revenue': (c_7days.sum(:budget) * 0.4).round(2),
        'top_3' =>       []
      }

      @r8_infos['campaign_30days'] = {
        'created_count': c_30days.count,
        'total_budget':  c_30days.sum(:budget).round(2),
        'total_revenue': (c_30days.sum(:budget) * 0.4).round(2),
        'top_3' =>       []
      }

      # top 3 有效点击最多的kol
      # res = CampaignShow.includes(:kol).find_by_sql("select kol_id, count(kol_id) as kolidcount from campaign_shows where created_at>'#{@ending - 1.days}' and created_at<'#{@ending}' and status=1 group by kol_id order by kolidcount desc limit 3;")

      # res.each do |ele|
      #   @r8_infos['campaign']['top_3'] << {
      #     'id':         ele.kol_id,
      #     'name':       ele.kol.name,
      #     'avatar_url': ele.kol.avatar_url,
      #     'count':      ele.kolidcount
      #   }
      # end

      @r8_infos['creation'] = {
        'created_count': Creation.recent(@ending - 1.day, @ending).count,
        'total_budget':  Tender.recent(@ending - 1.day, @ending).brand_paid.sum(:price).to_f.round(2),
        'total_revenue': Tender.recent(@ending - 1.day, @ending).brand_paid.sum(:fee).to_f.round(2),
        'kols' =>        []
      }

      @r8_infos['creation_7days'] = {
        'created_count': Creation.recent(@ending - 7.day, @ending).count,
        'total_budget':  Tender.recent(@ending - 7.day, @ending).brand_paid.sum(:price).to_f.round(2),
        'total_revenue': Tender.recent(@ending - 7.day, @ending).brand_paid.sum(:fee).to_f.round(2),
        'kols' =>        []
      }

      @r8_infos['creation_30days'] = {
        'created_count': Creation.recent(@ending - 30.day, @ending).count,
        'total_budget':  Tender.recent(@ending - 30.day, @ending).brand_paid.sum(:price).to_f.round(2),
        'total_revenue': Tender.recent(@ending - 30.day, @ending).brand_paid.sum(:fee).to_f.round(2),
        'kols' =>        []
      }

      # 所有的bigV按大V活动所赚的降序
      #tenders = Tender.includes(:kol).find_by_sql("select kol_id, sum(price) as pricesum from tenders where updated_at>'#{@ending - 1.days}' and updated_at<'#{@ending}' and status='paid' and head=false group by kol_id order by pricesum desc;")

      # tenders.each do |ele|
      #   @r8_infos['creation']['kols'] << {
      #     'id':         ele.kol_id,
      #     'name':       ele.kol.name,
      #     'avatar_url': ele.kol.avatar_url,
      #     'amount':     ele.pricesum.to_f
      #   }
      # end

      $redis.setex("r8_daily_info", 24.hours, @r8_infos.to_json)
    end
  end

  def edit_password
  end

  def update_password
  	current_admin_user.reset_password(params[:admin_user][:password], params[:admin_user][:password])
    if current_admin_user.errors.empty?
      flash[:notice] = "修改成功"
      redirect_to action: :index
    else
      flash[:alert] = "修改失败, 请重试. 注意: 密码要大于6位"
      render 'edit_password'
    end
  end
end
