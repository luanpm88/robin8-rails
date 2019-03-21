class MarketingDashboard::DashboardController < MarketingDashboard::BaseController

  def index
    @r8_infos = $redis.get("r8_daily_info")
    @ending   = Time.now.change({ hour: 19 })
    # @r8_infos = nil
    if @r8_infos
      @r8_infos = JSON @r8_infos
    else
      @r8_infos = {}
      
      @r8_infos['first_overall'] = {
        'today_kols_count':           Kol.where("created_at > ?", Date.today.to_time).count,
        'pending_campaigns_count':    Campaign.where(status: 'unexecute').realable.where("deadline >?", (Time.now-30.days)).count,
        'pending_screenshots_count':  CampaignInvite.where(img_status: :pending).where("screenshot is not NULL").count,
        'pending_tixians_count':      Withdraw.pending.count
      }

      _ary = Campaign.find_by_sql("select count(*) as c_count, sum(campaigns.budget)as c_budget from campaigns where status='settled'")

      @r8_infos['table'] = {
        'users_count':              User.count,
        'traded_users_count':       User.joins(:campaigns).group("campaigns.user_id").having("count(campaigns.id) > 0").count.keys.count,
        'kols_count':               Kol.count,
        # 'active_kols_count':        Kol.joins(:campaign_invites).where("campaign_invites.status ='settled'").group("campaign_invites.kol_id").having("count(campaign_invites.id) > 0").count.keys.count,
        # 活越用户，近6个月登录过
        'active_kols_count':        Kol.where('current_sign_in_at > ?', 6.months.ago).count,
        'settled_campaigns_count':  _ary.first.c_count,
        'settled_campaigns_amount': _ary.first.c_budget.to_f,
        'withdrawn_total_amount':   Withdraw.approved.sum(:credits).round
      }


      @r8_infos['kol'] = {
        'register_count': Kol.recent(@ending - 1.day, @ending).count,
        'active_count':   100
      }

      ary = WeiboAccount.recent(@ending - 1.day, @ending).map(&:status)
      @r8_infos['weibo']  = {
        'pending':  ary.count(0), 
        'passed':   ary.count(1), 
        'rejected': ary.count(-1)
      }

      _ary = PublicWechatAccount.recent(@ending - 1.day, @ending).map(&:status)
      @r8_infos['wechat'] = {
        'pending':  _ary.count(0), 
        'passed':   _ary.count(1), 
        'rejected': _ary.count(-1)
      }

      @r8_infos['big_v_count'] = ary.count + _ary.count

      @r8_infos['user'] = {
        'register_count': User.recent(@ending - 1.day, @ending).count
      }

      c = Campaign.where("start_time > ? and start_time < ?", @ending - 1.day, @ending).where(status: ['settled', 'executing', 'executed'])

      @r8_infos['campaign'] = {
        'created_count': c.count,
        'total_budget':  c.sum(:budget),
        'total_revenue': c.sum(:budget) * 0.4,
        'top_3' =>       []
      }

      # top 3 有效点击最多的kol
      res = CampaignShow.includes(:kol).find_by_sql("select kol_id, count(kol_id) as kolidcount from campaign_shows where created_at>'#{@ending - 1.days}' and created_at<'#{@ending}' and status=1 group by kol_id order by kolidcount desc limit 3;")

      res.each do |ele|
        @r8_infos['campaign']['top_3'] << {
          'id':         ele.kol_id,
          'name':       ele.kol.name,
          'avatar_url': ele.kol.avatar_url,
          'count':      ele.kolidcount
        }
      end

      @r8_infos['creation'] = {
        'created_count': Creation.recent(@ending - 1.day, @ending).count,
        'total_budget':  Tender.recent(@ending - 1.day, @ending).brand_paid.sum(:price).to_f,
        'total_revenue': Tender.recent(@ending - 1.day, @ending).brand_paid.sum(:fee),
        'kols' =>        []
      }

      # 所有的bigV按大V活动所赚的降序
      tenders = Tender.includes(:kol).find_by_sql("select kol_id, sum(price) as pricesum from tenders where updated_at>'#{@ending - 1.days}' and updated_at<'#{@ending}' and status='paid' and head=false group by kol_id order by pricesum desc;")

      tenders.each do |ele|
        @r8_infos['creation']['kols'] << {
          'id':         ele.kol_id,
          'name':       ele.kol.name,
          'avatar_url': ele.kol.avatar_url,
          'amount':     ele.pricesum.to_f
        }
      end

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
