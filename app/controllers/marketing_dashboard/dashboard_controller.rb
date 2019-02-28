class MarketingDashboard::DashboardController < MarketingDashboard::BaseController

  def index
    @r8_infos = $redis.hgetall("r8_daily_info")
    @ending   = Time.now.change({ hour: 19 })

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
        total_revenue: c.sum(:budget) * 0.4
      }

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
