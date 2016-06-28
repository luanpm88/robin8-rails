module Campaigns
  module CampaignProcess
    extend ActiveSupport::Concern

    included do
      SettleWaitTimeForKol = Rails.env.production?  ? 1.days  : 5.minutes
      SettleWaitTimeForBrand = Rails.env.production?  ? 4.days  : 10.minutes
      RemindUploadWaitTime =  Rails.env.production?  ? 3.days  : 1.minutes
    end

    def reset_campaign(origin_budget,new_budget, new_per_action_budget)
      Rails.logger.campaign.info "--------reset_campaign:  ---#{self.id}-----#{self.inspect} -- #{origin_budget}"
      self.user.unfrozen(origin_budget.to_f, 'campaign', self)
      Rails.logger.transaction.info "-------- reset_campaign:  after unfrozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
      if self.user.avail_amount >= self.budget.to_f
        self.user.frozen(new_budget.to_f, 'campaign', self)
        Rails.logger.transaction.info "-------- reset_campaign:  after frozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
      else
        Rails.logger.error("品牌商余额不足--reset_campaign - campaign_id: #{self.id}")
      end
    end

    # 开始时候就发送邀请 但是状态为pending
    def send_invites(kol_ids = nil)
      _start = Time.now
      Rails.logger.campaign_sidekiq.info "---send_invites: cid:#{self.id}--campaign status: #{self.status}---#{self.deadline}----kol_ids:#{kol_ids}-"
      return if self.status != 'agreed'
      self.update_attribute(:status, 'rejected') && return if self.deadline < Time.now
      Rails.logger.campaign_sidekiq.info "---send_invites: -----cid:#{self.id}--start create--"
      campaign_id = self.id
      Kol.where(:id => get_kol_ids).each do |kol|
        kol.add_campaign_id campaign_id
      end
      # make sure those execute late (after invite create)
      #招募类型 在报名开始时间 就要开始发送活动邀请 ,且在真正开始时间  需要把所有未通过的设置为审核失败
      if  is_recruit_type?
        _start_time = self.recruit_start_time < Time.now ? (Time.now + 5.seconds) : self.recruit_start_time
        CampaignWorker.perform_at(_start_time, self.id, 'start')
        CampaignWorker.perform_at(self.start_time, self.id, 'end_apply_check')
      else
        _start_time = self.start_time < Time.now ? (Time.now + 5.seconds) : self.start_time
        CampaignWorker.perform_at(_start_time, self.id, 'start')
      end
      CampaignWorker.perform_at(self.deadline ,self.id, 'end')
    end

    # 开始进行  此时需要更改invite状态
    def go_start
      Rails.logger.campaign_sidekiq.info "-----go_start:  ----start-----#{self.inspect}----------"
      ActiveRecord::Base.transaction do
        self.update_columns(:max_action => (budget.to_f / per_action_budget.to_f).to_i, :status => 'executing')
        self.cal_actual_per_action_budget
        Message.new_campaign(self, get_kol_ids)
      end
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
        end
      end
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

    # 更新invite 状态和点击数
    def end_invites
      campaign_invites.each do |invite|
        next if invite.status == 'finished' || invite.status == 'settled'  || invite.status == 'rejected'
        if invite.status == 'approved'
          invite.status = 'finished'
          invite.avail_click = invite.redis_avail_click.value
          invite.total_click = invite.redis_total_click.value
        elsif
          # receive but not apporve  we must delete
          invite.delete
        end
        invite.save!
      end
    end

    # 结算 for kol
    def settle_accounts_for_kol
      Rails.logger.transaction.info "-------- settle_accounts_for_kol: cid:#{self.id}------status: #{self.status}"
      return if self.status != 'executed'
      self.finish_need_check_invites.update_all({:img_status => 'passed', :auto_check => true})
      self.passed_invites.each do |invite|
        kol = invite.kol
        invite.update_column(:status, 'settled')
        if is_click_type? or is_cpa_type?
          kol.income(invite.avail_click * self.get_per_action_budget(false), 'campaign', self, self.user)
          Rails.logger.info "-------- settle_accounts_for_kol:  ---cid:#{self.id}--kol_id:#{kol.id}----credits:#{invite.avail_click * self.get_per_action_budget(false)}-- after avail_amount:#{kol.avail_amount}"
        else
          kol.income(self.get_per_action_budget(false), 'campaign', self, self.user)
          Rails.logger.info "-------- settle_accounts_for_kol:  ---cid:#{self.id}--kol_id:#{kol.id}----credits:#{self.get_per_action_budget(false)}-- after avail_amount:#{kol.avail_amount}"
        end
      end
    end

    # 结算 for brand
    def settle_accounts_for_brand
      Rails.logger.transaction.info "-------- settle_accounts_for_brand: cid:#{self.id}------status: #{self.status}"
      return if self.status != 'executed'
      #首先先付款给期间审核的kol
      self.finish_need_check_invites.update_all({:img_status => 'passed', :auto_check => true})
      settle_accounts_for_kol
      #剩下的邀请  状态全设置为拒绝
      if self.campaign_from == "app"
        self.update_column(:status, 'settled')
        # self.user.unfrozen(self.budget, 'campaign', self)
        Rails.logger.transaction.info "-------- settle_accounts: user  after unfrozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
        if is_click_type?  || is_cpa_type?
          pay_total_click = self.settled_invites.sum(:avail_click)
          User.get_platform_account.income((pay_total_click * (per_action_budget - actual_per_action_budget)), 'campaign_tax', self)
          if (self.budget - (pay_total_click * self.per_action_budget)) > 0
            self.user.income(self.budget - (pay_total_click * self.per_action_budget) , 'campaign_refund', self )
          end
          Rails.logger.transaction.info "-------- settle_accounts: user-------fee:#{pay_total_click * per_action_budget} --- after payout ---cid:#{self.id}-----#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}---\n"
        else
          settled_invite_size = self.settled_invites.size
          User.get_platform_account.income(((per_action_budget - actual_per_action_budget) * settled_invite_size), 'campaign_tax', self)

          if (self.budget - (self.per_action_budget * settled_invite_size) ) > 0
            self.user.income(self.budget - (self.per_action_budget * settled_invite_size) , 'campaign_refund', self )
          end

          Rails.logger.transaction.info "-------- settle_accounts: user-------fee:#{per_action_budget  * settled_invite_size} --- after payout ---cid:#{self.id}-----#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}---\n"
        end
      else
        self.update_column(:status, 'settled')
        self.user.unfrozen(self.budget, 'campaign', self)
        Rails.logger.transaction.info "-------- settle_accounts: user  after unfrozen ---cid:#{self.id}--user_id:#{self.user.id}---#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}"
        if is_click_type?  || is_cpa_type?
          pay_total_click = self.settled_invites.sum(:avail_click)
          User.get_platform_account.income((pay_total_click * (per_action_budget - actual_per_action_budget)), 'campaign_tax', self)
          self.user.payout((pay_total_click * self.per_action_budget) , 'campaign', self )
          Rails.logger.transaction.info "-------- settle_accounts: user-------fee:#{pay_total_click * per_action_budget} --- after payout ---cid:#{self.id}-----#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}---\n"
        else
          settled_invite_size = self.settled_invites.size
          User.get_platform_account.income(((per_action_budget - actual_per_action_budget) * settled_invite_size), 'campaign_tax', self)
          self.user.payout((self.per_action_budget * settled_invite_size) , 'campaign', self )
          Rails.logger.transaction.info "-------- settle_accounts: user-------fee:#{per_action_budget  * settled_invite_size} --- after payout ---cid:#{self.id}-----#{self.user.avail_amount.to_f} ---#{self.user.frozen_amount.to_f}---\n"
        end
      end
    end

    def cal_actual_per_action_budget
      if is_click_type?
        actual_per_budget = (self.per_action_budget * 0.7).round(2)
        point1, point2 = actual_per_budget.divmod(0.1)
        point2 = point2.round(2)
        if point2 >= 0.08
          actual_per_action_budget = (point1 + 1) * 0.1
        elsif point2 >= 0.03
          actual_per_action_budget = point1 * 0.1 + 0.05
        else
          actual_per_action_budget = point1 * 0.1
        end
        actual_per_action_budget = actual_per_action_budget.round(2)
      elsif is_recruit_type?
        actual_per_action_budget = (self.per_action_budget * 0.7).round(0)
      else
        actual_per_action_budget = (self.per_action_budget * 0.7).round(1)
      end
      self.update_column(:actual_per_action_budget, actual_per_action_budget)
    end

    def add_click(valid)
      Rails.logger.campaign_show_sidekiq.info "---------Campaign add_click: --valid:#{valid}----status:#{self.status}---avail_click:#{self.redis_avail_click.value}---#{self.redis_total_click.value}-"
      self.redis_avail_click.increment  if valid
      self.redis_total_click.increment
      if self.redis_avail_click.value.to_i >= self.max_action.to_i && self.status == 'executing' && (self.per_budget_type == "click" or self.is_cpa_type?)
        finish('fee_end')
      end
    end

    # 提醒上传截图
    def remind_upload
      Rails.logger.campaign_sidekiq.info "-----remind_upload:  ----start-----#{self.inspect}----------"
      Message.new_remind_upload(self)
    end

    class_methods do
      PushStartHour = 9
      PushEndHour = 18
      PushInterval = Rails.env.production? ? 3.hours  : 5.minutes
      def can_push_message(campaign)
        now =  Time.now
        # notice : recruit cmapaign start_time is after
        last_campaign = Campaign.where(:status => ['executing', 'executed', 'settled']).where("start_time < '#{now}'").where.not(:id => campaign.id).order("start_time desc").first
        if now.hour >= PushStartHour && now.hour < PushEndHour  && (now - PushInterval > last_campaign.start_time)
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

