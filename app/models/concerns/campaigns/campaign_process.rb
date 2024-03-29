module Campaigns
  module CampaignProcess
    extend ActiveSupport::Concern

    included do
      SettleWaitTimeForKol = Rails.env.production?  ? 1.days  : 5.minutes
      SettleWaitTimeForBrand = Rails.env.production?  ? 4.days  : 10.minutes
      RemindUploadWaitTime =  Rails.env.production?  ? 3.days  : 1.minutes
      KolBudgetRate = 0.6
      AppendWaitTime =  Rails.env.production?  ? 6.hours  : 5.minutes
    end

    def pay
      ActiveRecord::Base.transaction do
        if self.pay_way == 'balance'
          self.user.payout(self.need_pay_amount, 'campaign', self)
          Rails.logger.transaction.info "-------- 执行user payout: ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.inspect}"
        elsif self.pay_way == 'alipay'
          self.user.payout_by_alipay(self.need_pay_amount, 'campaign_pay_by_alipay', self)
          alipay_status_tmp = 1
          Rails.logger.transaction.info "-------- 执行user pay_by_alipay: ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.inspect}"
        end
        if self.used_voucher
          self.user.kol.unfrozen(self.voucher_amount, 'campaign_used_voucher', self)
          Rails.logger.transaction.info "-------- use voucher ------- 执行kol unfrozen ---cid:#{self.id}--user_id:#{self.user.kol_id}---#{self.user.kol.inspect}"
          self.user.kol.payout(self.voucher_amount, 'campaign_used_voucher', self)
          Rails.logger.transaction.info "-------- use voucher ------- 执行kol payout ---cid:#{self.id}--user_id:#{self.user.kol_id}---#{self.user.kol.inspect}"
        end
        self.need_pay_amount = 0
        self.status = 'unexecute'
        self.alipay_status = alipay_status_tmp
        self.save!
      end
    end

    def revoke
      ActiveRecord::Base.transaction do
        if self.status == 'unpay'
          if self.used_voucher
            self.user.kol.unfrozen(self.budget - self.need_pay_amount, "campaign_revoke", self)
            Rails.logger.transaction.info "--------活动撤销退款给kol, 执行kol unfrozen:  ---cid:#{self.id}--status:#{self.status}--kol_id:#{self.user.kol_id}---#{self.user.kol.inspect}"
          end
          self.update_attributes!(status: "revoked", revoke_time: Time.now)
        elsif %w(unexecute rejected).include? self.status
          # 返还积分
          if used_credit && credit_amount > 0
            Credit.gen_record('refund', 1, credit_amount, user, self, user.credit_expired_at, "活动: #{id} 退还")
            pay_amount = budget - credit_amount.to_f/10
            self.user.income(pay_amount, "campaign_revoke", self) if pay_amount > 0
          else
            if self.used_voucher
              self.user.kol.income(self.voucher_amount, 'campaign_used_voucher_and_revoke', self)
              Rails.logger.transaction.info "--------活动撤销退款给kol, 执行kol income: ---cid:#{self.id}--status:#{self.status}--kol_id:#{self.user.kol_id}---#{self.user.kol.inspect}"
            end

            if(self.budget - self.voucher_amount) > 0
              self.user.income(self.budget - self.voucher_amount, "campaign_revoke", self)
            end
          end

          Rails.logger.transaction.info "--------活动撤销退款给user, 执行kol income: ---cid:#{self.id}--status:#{self.status}--kol_id:#{self.user.kol_id}---#{self.user.kol.inspect}"
          self.update_attributes!(status: 'revoked', revoke_time: Time.now)
        end
      end
    end

    def reset_campaign(origin_budget,new_budget, new_per_action_budget)
      Rails.logger.campaign.info "--------reset_campaign:  ---#{self.id}-----#{self.inspect} -- #{origin_budget}"
      self.user.unfrozen(origin_budget.to_f, 'campaign', self)
      Rails.logger.transaction.info "-------- reset_campaign:  after unfrozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
      if self.user.avail_amount >= self.budget.to_f
        self.user.frozen(new_budget.to_f, 'campaign', self)
        Rails.logger.transaction.info "-------- reset_campaign:  after frozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
      else
        Rails.logger.transaction.error("品牌商余额不足--reset_campaign - campaign_id: #{self.id}")
      end
    end

    # 开始时候就发送邀请 但是状态为pending
    # 由于活动审核时候获得kol_id可能和活动开始获得的推送kol_id 可能不一致,所以干脆都在go_start 进行发送+ 推送
    # def send_invites(kol_ids = nil)
    #   _start = Time.now
    #   Rails.logger.campaign_sidekiq.info "---send_invites: cid:#{self.id}--campaign status: #{self.status}---#{self.deadline}----kol_ids:#{kol_ids}-"
    #   return if self.status != 'agreed'
    #   self.update_attribute(:status, 'rejected') && return if self.deadline < Time.now
    #   if self.is_invite_type?
    #     self.update_columns(:max_action => 1)
    #   else
    #     self.update_columns(:max_action => (budget.to_f / per_action_budget.to_f).to_i)
    #     self.update_column(:actual_per_action_budget, self.cal_actual_per_action_budget)  if  self.actual_per_action_budget.blank?
    #   end
    #   # make sure those execute late (after invite create)
    #   #招募类型 在报名开始时间 就要开始发送活动邀请 ,且在真正开始时间  需要把所有未通过的设置为审核失败
    #   campaign_id = self.id
    #   kols = get_kol_ids(true, kol_ids, true)
    #   kols.each {|kol|  kol.add_campaign_id campaign_id }  if kols.present?
    #   kol_ids = kols.select(:id).map(&:id) rescue []

    #   _start_time = self.is_recruit_type?? self.recruit_start_time : self.start_time

    #   if _start_time > (Time.now + 20.minutes)
    #     push_time = _start_time - 10.minutes
    #     CampaignWorker.perform_at(push_time, self.id, 'countdown')
    #     MessageWorker.perform_at(push_time, self.id, kol_ids )
    #   end

    #   _start_time = start_time < Time.now ? (Time.now + 5.seconds) : _start_time
    #   CampaignWorker.perform_at(_start_time, self.id, 'start')
    #   CampaignWorker.perform_at(self.deadline, self.id, 'end')
    #   CampaignWorker.perform_at(self.start_time, self.id, 'end_apply_check') if self.is_recruit_type?
    # end
    def send_invites(kol_ids=nil)
      Rails.logger.campaign_sidekiq.info "---send_invites: cid:#{self.id}--campaign status: #{self.status}---#{self.deadline}----kol_ids:#{kol_ids}-"
      return if status != 'agreed'
      self.update_attributes(status: 'rejected') && return if deadline < Time.now

      _update_hash = {}
      if self.is_invite_type?
        _update_hash[:max_action] = 1
      else
        _update_hash[:max_action] = (budget.to_f / per_action_budget.to_f).to_i
        _update_hash[:actual_per_action_budget] = cal_actual_per_action_budget  if  self.actual_per_action_budget.blank?
      end
      self.update_columns(_update_hash)

      # make sure those execute late (after invite create)
      #招募类型 在报名开始时间 就要开始发送活动邀请 ,且在真正开始时间  需要把所有未通过的设置为审核失败
      kols = get_kol_ids(true, kol_ids, true)
      kols.each {|kol| kol.add_campaign_id(self.id)}  if kols.present?
      kol_ids = kols.select(:id).map(&:id)

      _start_time = is_recruit_type? ? recruit_start_time : start_time

      if _start_time > 20.minutes.since
        CampaignWorker.perform_at(_start_time.ago(10.minutes), self.id, 'countdown')
        MessageWorker.perform_at(_start_time.ago(10.minutes), self.id, kol_ids )
      end

      CampaignWorker.perform_at(_start_time, self.id, 'start')
      CampaignWorker.perform_at(self.deadline, self.id, 'end')
      CampaignWorker.perform_at(self.start_time, self.id, 'end_apply_check') if self.is_recruit_type?
    end

    def go_start(kol_ids = nil)
      ActiveRecord::Base.transaction do
        #raise 'kol not set price' if  self.is_invite_type? && self.campaign_invites.any?{|t| t.price.blank?}
        self.update_columns(:status => 'executing')
      end
      if (self.is_post_type? || self.is_simple_cpi_type? || self.is_click_type?)  && self.enable_append_push
        CampaignWorker.perform_at(Time.now + AppendWaitTime, self.id, 'timed_append_kols')
      end
      Rails.logger.campaign_sidekiq.info "-----go_start:  ----start-----#{self.inspect}----------"
    end

    def timed_append_kols
      return unless self.status == 'executing'

      filter_types = ["tags", "age", "region", "gender"]
      filter_types = filter_types & self.campaign_targets.where.not(target_content: "全部").map(&:target_type)
      filter_types = filter_types - self.campaign_push_records.map(&:converted_target_type)
      return if filter_types.blank?

      removed_type = filter_types.shift
      kol_ids = self.get_remaining_kol_ids(filter_types)

      if kol_ids.present?
        Kol.where(id: kol_ids).each { |k| k.add_campaign_id(self.id, true) }
        Message.new_campaign(self.id, kol_ids)
      end

      CampaignPushRecord.create(
        campaign_id: self.id,
        kol_ids: kol_ids.join(","),
        push_type: "append",
        filter_type: "match",
        filter_reason: "#{removed_type}_target_removed"
      )

      unless filter_types.blank?
        timed_at = CampaignPushRecord.restrict_to_time_range(AppendWaitTime)
        CampaignWorker.perform_at(timed_at, self.id, "timed_append_kols")
      end
    end

    def push_all_kols
      should_push_kol_is = []
      Kol.active.where("forbid_campaign_time is null or forbid_campaign_time <'#{Time.now}'").each do |kol|
        unless kol.receive_campaign_ids.include?(kol.id.to_s)
          kol.add_campaign_id self.id, false
          should_push_kol_is << kol.id
        end
      end
      # CampaignPushRecordWorker.new.perform(self.id, 'push_all', should_push_kol_is)
    end

    #finish_remark:  expired or fee_end
    def finish(finish_remark)
      self.reload
      Rails.logger.campaign_sidekiq.info "-----executed: #{finish_remark}----------"
      if self.status == 'executing'
        ActiveRecord::Base.transaction do
          update_info(finish_remark)
          end_invites
          settle_accounts_for_kol
          if !Rails.env.test?
            CampaignWorker.perform_at(Time.now + SettleWaitTimeForKol ,self.id, 'settle_accounts_for_kol')
            CampaignWorker.perform_at(self.cal_settle_time ,self.id, 'settle_accounts_for_brand')
            CampaignWorker.perform_at(Time.now + RemindUploadWaitTime ,self.id, 'remind_upload')
            CampaignObserverWorker.perform_async(self.id)
          elsif Rails.env.test?
            CampaignWorker.new.perform(self.id, 'settle_accounts_for_kol')
            CampaignWorker.new.perform(self.id, 'settle_accounts_for_brand')
            CampaignWorker.new.perform(self.id, 'remind_upload')
            CampaignObserverWorker.new.perform(self.id)
          end
          Partners::Alizhongbao.finish_campaign(self.id)  if self.channel == 'azb'
          self.generate_campaign_e_wattle_transactions
        end
      elsif self.status == 'agreed'
        ActiveRecord::Base.transaction do
          self.update_attributes(:avail_click => self.redis_avail_click.value, :total_click => self.redis_total_click.value,
                                 :status => 'executed', :finish_remark => finish_remark, :actual_deadline_time => Time.now)
          settle_accounts_for_brand
        end
      end
    end

    #招募活动开始时 发送通知
    def push_start_notify
      title = "您参与的Robin8招募活动，已经开始啦。复制活动素材转发到朋友圈，即可获得#{self.actual_per_action_budget}元奖励。"
      kol_ids = self.valid_invites.collect{|i| i.kol_id }
      kols = Kol.where(:id => kol_ids)
      Rails.logger.sms.info "-----kols size:##{kols.size} --- #{kols.collect{|k| k.mobile_number}.inspect rescue nil}"
      return if kols.size == 0
      # 发送短信通知
      Emay::SendSms.to(kols.collect{|k| k.mobile_number}.compact, title)
      #发送通知
      PushMessage.push_common_message(kols, title, '您参与的招募活动已经开始啦!', self)
    end

    def cal_settle_time(end_time = nil)
      time = (end_time ||  Time.now) + SettleWaitTimeForBrand
      # 周六或者周日，或者周五17点后，都调整到下周15：00
      if time.wday == 6 || time.wday == 0 || (time.wday == 5 && time.hour >= 17)
        time = time.end_of_week + 15.hours
      elsif  time.wday == 1 && time.hour < 15        #周一15点前：也调整到15点
        time = time.beginning_of_week + 15.hours
      end
      time
    end


    def update_info(finish_remark)
      self.update_attributes(
        avail_click:          self.redis_avail_click.value,
        total_click:          self.redis_total_click.value,
        status:               'executed',
        finish_remark:        finish_remark,
        actual_deadline_time: Time.now
      )
    end

    # 更新invite 状态和点击数 (Update the invite state and the number of hits)
    # Changes campaign invites status from approved=>finished
    # and updates number of clicks basing on clicks collected in Redis
    def end_invites
      # ['pending', 'running', 'applying', 'approved', 'finished', 'rejected', "settled"]
      campaign = self
      campaign_invites.each do |invite|
        next if invite.status == 'finished' || invite.status == 'settled'  || invite.status == 'rejected'
        if invite.status == 'approved'
          invite.status = 'finished'
          invite.avail_click = invite.redis_avail_click.value
          invite.total_click = invite.redis_total_click.value
          # recruit campaign upload img after campaign finished
          # if invite.total_click == 0 && invite.img_status == 'pending' && (campaign.is_post_type?  || campaign.is_click_type? || campaign.is_cpa_type?)
          #   invite.img_status = 'rejected'
          #   invite.reject_reason = '活动一次点击都没有'
          # end
          invite.save!
        else
          # Received but not approved should be removed. Here we're only soft-deleting it,
          # cronjob removes old invitations after few days
          CampaignInvite.unscoped.find(invite.id).update(deleted: true)
        end
      end
    end

    # 结算 for kol
    def settle_accounts_for_kol
      Rails.logger.transaction.info "-------- settle_accounts_for_kol: cid:#{self.id}------status: #{self.status}"
      return if self.status != 'executed'
      self.passed_invites.each do |invite|
        invite.settle
      end
    end

    # 结算 for brand
    def settle_accounts_for_brand
      Rails.logger.transaction.info "-------- settle_accounts_for_brand: cid:#{self.id}------status: #{self.status}"
      # 一个user针对一个campaign只能产生一条campaign_refund # evan 2018.2.28 11:00am
      return unless Transaction.where(account: self.user, direct: 'income', item: self, subject: "campaign_refund").empty?
      return if self.status != 'executed'
      
      #首先先付款给期间审核的kol, 剩下的邀请状态全设置为拒绝
      self.wait_pass_invites.update_all({img_status: 'passed', auto_check: true}) if self.is_click_type?
      self.finish_need_check_invites.update_all({img_status: 'passed', auto_check: true}) unless self.is_invite_type?

      self.campaign_invites.should_reject.update_all({status: 'rejected', img_status: 'rejected', auto_check: true})
       
      settle_accounts_for_kol
      
      self.update_columns(status: 'settled', evaluation_status: 'evaluating')
      
      Rails.logger.transaction.info "-------- settle_accounts: user  after unfrozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
      
      # 平台收益
      platform_income_amount   = 0
      # 活动剩余
      remaining_budget         = 0
      actual_per_action_budget = self.actual_per_action_budget ||  self.per_action_budget
      
      if is_click_type? || is_cpa_type? || is_cpi_type?
        pay_total_click         = self.settled_invites.sum(:avail_click)
        platform_income_amount  = pay_total_click * (per_action_budget - actual_per_action_budget)
        remaining_budget        = self.budget - (pay_total_click * self.per_action_budget)
        
        Rails.logger.transaction.info "-------- settle_accounts: user-------fee:#{pay_total_click * per_action_budget} --- after payout ---cid:#{self.id}-----#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}---\n"
      elsif is_invite_type?
        user_payout             = self.campaign_invites.settled.sum(:sale_price)
        platform_income_amount  = user_payout -  self.campaign_invites.settled.sum(:price)
        remaining_budget        = self.budget - user_payout
      else
        settled_invite_size     = self.settled_invites.size
        platform_income_amount  = (per_action_budget - actual_per_action_budget) * settled_invite_size
        remaining_budget        = self.budget - (self.per_action_budget * settled_invite_size)
        
        Rails.logger.transaction.info "-------- settle_accounts: user-------fee:#{per_action_budget  * settled_invite_size} --- after payout ---cid:#{self.id}-----#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}---\n"
      end

      plattform_gains(platform_income_amount) if platform_income_amount > 0
      refund_brand(remaining_budget)          if remaining_budget > 0
    end

    # 平台收益
    def plattform_gains(platform_income_amount)
      User.get_platform_account.income(platform_income_amount, 'campaign_tax', self)
    end

    # 由于加了积分抵扣（先消耗积分，再消耗钱），所以退还未消耗的部分也有可能是(积分，钱， 积分+钱)
    def refund_brand(remaining_budget)
      pay_amount = self.budget - credit_amount.to_f/10
      # 总金额为以积分全部支付
      if used_credit && remaining_budget > pay_amount
        self.user.income(pay_amount, 'campaign_refund', self)
        Credit.gen_record('refund', 1, ((remaining_budget - pay_amount) * 10).to_i, self.user, self, self.user.credit_expired_at, "活动未消耗: #{self.id} 退还")
      else
        self.user.income(remaining_budget, 'campaign_refund', self)
      end
    end

    def cal_actual_per_action_budget
      (self.per_action_budget * KolBudgetRate).round(2)  rescue nil
    end

    def add_click(valid, only_increment_avail = false)
      Rails.logger.campaign_show_sidekiq.info "---------Campaign add_click: --valid:#{valid}----status:#{self.status}---avail_click:#{self.redis_avail_click.value}---#{self.redis_total_click.value}-"
      self.redis_avail_click.increment  if valid
      self.redis_total_click.increment  if only_increment_avail == false
      if self.redis_avail_click.value.to_i >= self.max_action.to_i && self.status == 'executing' && (self.per_budget_type == "click" or self.is_cpa_type?  or self.is_cpi_type?)
        finish('fee_end')
      end
    end

    # 提醒上传截图
    def remind_upload
      Rails.logger.campaign_sidekiq.info "-----remind_upload:  ----start-----#{self.inspect}----------"
      Message.new_remind_upload(self)
    end

    # 活动倒计时
    def campaign_countdown
      Rails.logger.campaign_sidekiq.info "----countdown: #{self.id}-----------"
      return if self.status != 'agreed'
      self.update_columns(status: 'countdown')
    end

    class_methods do
      def can_push_message(campaign)
        (8...22).include? Time.now.hour
      end

      def today_had_pushed_message
        Campaign.where(status: ['executing', 'executed']).where("start_time > '#{Time.now.at_midday.ago(4.hours)}'").count > 0
      end
    end

  end
end
