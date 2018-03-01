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
          if self.used_voucher
            self.user.kol.income(self.voucher_amount, 'campaign_used_voucher_and_revoke', self)
            Rails.logger.transaction.info "--------活动撤销退款给kol, 执行kol income: ---cid:#{self.id}--status:#{self.status}--kol_id:#{self.user.kol_id}---#{self.user.kol.inspect}"
          end

          if(self.budget - self.voucher_amount) > 0
            self.user.income(self.budget - self.voucher_amount, "campaign_revoke", self)
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
    def send_invites(kol_ids = nil)
      _start = Time.now
      Rails.logger.campaign_sidekiq.info "---send_invites: cid:#{self.id}--campaign status: #{self.status}---#{self.deadline}----kol_ids:#{kol_ids}-"
      return if self.status != 'agreed'
      self.update_attribute(:status, 'rejected') && return if self.deadline < Time.now
      if self.is_invite_type?
        self.update_columns(:max_action => 1)
      else
        self.update_columns(:max_action => (budget.to_f / per_action_budget.to_f).to_i)
        self.update_column(:actual_per_action_budget, self.cal_actual_per_action_budget)  if  self.actual_per_action_budget.blank?
      end
      # make sure those execute late (after invite create)
      #招募类型 在报名开始时间 就要开始发送活动邀请 ,且在真正开始时间  需要把所有未通过的设置为审核失败

      if  is_recruit_type?
        _start_time = self.recruit_start_time < Time.now ? (Time.now + 15.minutes) : self.recruit_start_time
        _push_message_time = _start_time - 10.minutes
        CampaignWorker.perform_at(_start_time, self.id, 'start')
        CampaignWorker.perform_at(self.start_time, self.id, 'end_apply_check')
        MessageWorker.perform_at(_push_message_time , self.id , self.get_kol_ids(false, [] , true) ) 
      else
        _start_time = self.start_time < Time.now ? (Time.now + 15.minutes) : self.start_time
        _push_message_time = _start_time - 10.minutes
        CampaignWorker.perform_at(_start_time, self.id, 'start')
        MessageWorker.perform_at(_push_message_time , self.id , self.get_kol_ids(false, [] , true) )
      end
      CampaignWorker.perform_at(self.deadline ,self.id, 'end')

    end

    def go_start(kol_ids = nil)
      Rails.logger.campaign_sidekiq.info "-----go_start:  ----start-----#{self.inspect}----------"
      return if self.status != 'agreed'
      ActiveRecord::Base.transaction do
        #raise 'kol not set price' if  self.is_invite_type? && self.campaign_invites.any?{|t| t.price.blank?}
        self.update_columns(:status => 'executing')
        campaign_id = self.id
        kols = get_kol_ids(true, kol_ids)
        # Rails.logger.campaign_sidekiq.info "----cid:#{self.id}----kol_ids:#{kol_ids.inspect}"
        # send_invite
        kols.each {|kol|  kol.add_campaign_id campaign_id }  if kols.present?
        # Kol.where(:id => kol_ids).each do |kol|
        #   kol.add_campaign_id campaign_id
        # end
        # 发送通知
        # Message.new_campaign(self, kol_ids)
      end
      if (self.is_post_type? || self.is_simple_cpi_type? || self.is_click_type?)  && self.enable_append_push
        CampaignWorker.perform_at(Time.now + AppendWaitTime, self.id, 'timed_append_kols')
      end
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
      self.update_attributes(:avail_click => self.redis_avail_click.value, :total_click => self.redis_total_click.value,
                             :status => 'executed', :finish_remark => finish_remark, :actual_deadline_time => Time.now)
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
       #首先先付款给期间审核的kol
       self.finish_need_check_invites.update_all({:img_status => 'passed', :auto_check => true})      unless self.is_invite_type?
       #剩下的邀请  状态全设置为拒绝
       self.campaign_invites.should_reject.update_all({:status => 'rejected', :img_status => 'rejected', :auto_check => true})
       settle_accounts_for_kol
       self.update_columns(status: 'settled', evaluation_status: 'evaluating')
       Rails.logger.transaction.info "-------- settle_accounts: user  after unfrozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
       actual_per_action_budget = (self.actual_per_action_budget ||  self.per_action_budget)
       if is_click_type?  || is_cpa_type? || is_cpi_type?
         pay_total_click = self.settled_invites.sum(:avail_click)
         User.get_platform_account.income((pay_total_click * (per_action_budget - actual_per_action_budget)), 'campaign_tax', self)
         if (self.budget - (pay_total_click * self.per_action_budget)) > 0
           self.user.income(self.budget - (pay_total_click * self.per_action_budget) , 'campaign_refund', self )
         end
         Rails.logger.transaction.info "-------- settle_accounts: user-------fee:#{pay_total_click * per_action_budget} --- after payout ---cid:#{self.id}-----#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}---\n"
       elsif is_invite_type?
         user_payout = self.campaign_invites.settled.sum(:sale_price)
         kol_income_amount = self.campaign_invites.settled.sum(:price)
         platform_income_amount = user_payout -  kol_income_amount
         User.get_platform_account.income(platform_income_amount, 'campaign_tax', self)
         if self.budget > user_payout
           self.user.income(self.budget - user_payout , 'campaign_refund', self )
         end
       else
         settled_invite_size = self.settled_invites.size
         User.get_platform_account.income(((per_action_budget - actual_per_action_budget) * settled_invite_size), 'campaign_tax', self)

         if (self.budget - (self.per_action_budget * settled_invite_size) ) > 0
           self.user.income(self.budget - (self.per_action_budget * settled_invite_size) , 'campaign_refund', self )
         end

         Rails.logger.transaction.info "-------- settle_accounts: user-------fee:#{per_action_budget  * settled_invite_size} --- after payout ---cid:#{self.id}-----#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}---\n"
       end
     end

    def cal_actual_per_action_budget
      actual_per_action_budget = (self.per_action_budget * KolBudgetRate).round(2)  rescue nil
      actual_per_action_budget
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

    class_methods do
      PushStartHour = 8
      PushEndHour = 22
      PushInterval = Rails.env.production? ? 3.hours  : 5.minutes
      def can_push_message(campaign)
        now =  Time.now
        if now.hour >= PushStartHour && now.hour < PushEndHour
          return true
        else
          return false
        end
      end

      def today_had_pushed_message
        Campaign.where(:status => ['executing', 'executed']).where("start_time > '#{Date.today.to_s} #{PushStartHour}:00'").count > 0 ? true : false
      end
    end

  end
end
