class MarketingDashboard::DashboardController < MarketingDashboard::BaseController

  def index
    @r8_infos = $redis.hgetall("r8_daily_info")
    @ending   = Time.now.change({ hour: 19 })
    # @r8_infos = {}
    if @r8_infos.empty?
      @r8_infos[:kol] = {
        register_count: Kol.recent(@ending - 1.day, @ending).count,
        active_count:   100
      }

      weibo = WeiboAccount.recent(@ending - 1.day, @ending)
      @r8_infos[:weibo]  = {
        pending:  weibo.by_status(0).count, 
        passed:   weibo.by_status(1).count, 
        rejected: weibo.by_status(-1).count
      }

      wechat = PublicWechatAccount.recent(@ending - 1.day, @ending)
      @r8_infos[:wechat] = {
        pending:  wechat.by_status(0).count, 
        passed:   wechat.by_status(1).count, 
        rejected: wechat.by_status(-1).count
      }

      @r8_infos[:big_v_count] = weibo.count + wechat.count

      @r8_infos[:user] = {
        register_count: User.recent(@ending - 1.day, @ending).count
      }

      c = Campaign.where("start_time > ? and start_time < ?", @ending - 1.day, @ending).where(status: ['settled', 'executing', 'executed'])

      @r8_infos[:campaign] = {
        created_count: c.count,
        total_budget:  c.sum(:budget),
        total_revenue: c.sum(:budget) * 0.4,
        top_3:         []
      }

      # top 3 有效点击最多的kol
      res = CampaignShow.includes(:kol).find_by_sql("select kol_id, count(kol_id) as kolidcount from campaign_shows where created_at>'#{@ending - 1.days}' and created_at<'#{@ending}' and status=1 group by kol_id order by kolidcount desc limit 3;")

      res.each do |ele|
        @r8_infos[:campaign][:top_3] << {
          id:         ele.kol_id,
          name:       ele.kol.name,
          avatar_url: ele.kol.avatar_url,
          count:      ele.kolidcount
        }
      end

      @r8_infos[:creation] = {
        created_count: Creation.recent(@ending - 1.day, @ending).count,
        total_budget:  Tender.recent(@ending - 1.day, @ending).brand_paid.sum(:price).to_f,
        total_revenue: Tender.recent(@ending - 1.day, @ending).brand_paid.sum(:fee),
        kols:          []
      }

      # 所有的bigV按大V活动所赚的降序
      tenders = Tender.includes(:kol).find_by_sql("select kol_id, sum(price) as pricesum from tenders where updated_at>'#{@ending - 1.days}' and updated_at<'#{@ending}' and status='paid' and head=false group by kol_id order by pricesum desc;")

      tenders.each do |ele|
        @r8_infos[:creation][:kols] << {
          id:         ele.kol_id,
          name:       ele.kol.name,
          avatar_url: ele.kol.avatar_url,
          amount:     ele.pricesum.to_f
        }
      end

      $redis.expire("r8_daily_info", 24.hours)
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
