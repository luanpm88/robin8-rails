class Transaction < ActiveRecord::Base
  belongs_to :account, :polymorphic => true
  belongs_to :opposite, :polymorphic => true
  belongs_to :item, :polymorphic => true

  scope :recent, ->(_start,_end){ where(:created_at => _start.beginning_of_day.._end.end_of_day) }
  scope :created_desc, -> {order('created_at desc')}
  scope :tasks, ->{where("subject in ('check_in', 'invite_friend', 'complete_info')")}

  # kol 和braand 行为有差异  现落到各自model
  # scope :income, -> {where(:direct => 'income')}
  # scope :withdraw, -> {where(:direct => 'payout')}
  validates_inclusion_of :subject, in: %w(campaign manual_recharge manual_withdraw withdraw check_in  invite_friend  complete_info favorable_comment)

  # subject
  # manual_recharge manual_withdraw

  def get_subject
    case subject
      when 'campaign'
        "营销活动(#{self.item.name})"
      when 'manual_recharge'
        '人工充值'
      when 'manual_withdraw'
        '人工提现'
      when 'withdraw'
        '提现'
    end

  end

  def get_direct
    case direct
      when 'income'
        then '收入'
      when 'payout'
        then '支出'
      when 'frozen'
        then '冻结'
      when 'unfrozen'
        then '解冻'
    end
  end


  ImgDomian = Rails.application.secrets[:qiniu][:bucket_domain]
  AccountNotices = [
                    {:question => "可提现的金额什么意思？", :answer => '您参加活动后被审核通过，等待整个活动时间结束，酬劳就会由“预计收入”中的金额变成“可提现”金额。' , :logo => "http://#{ImgDomian}/question_icon1%402x.png"},
                    {:question => "提现中什么意思？", :answer => '正在提现过程中系统冻结的金额。', :logo => "http://#{ImgDomian}/question_icon2%402x.png" },
                    {:question => "已提现什么意思？", :answer => '您已成功提现的金额。' , :logo => "http://#{ImgDomian}/question_icon3%402x.png" },
                    {:question => '提现需要几天？为什么金额一直是“提现中”？', :answer => '从您提交提现申请开始，ROBIN8将在3个工作日内为您尽快处理，在此期间您的提现金额将会处于“提现中”的状态。', :logo => "http://#{ImgDomian}/question_icon4%402x.png"},
                    {:question => '如何修改支付宝绑定？', :answer => '为保证账户安全，在您提现成功后一个月内将不可以修改支付宝绑定，如有紧急情况请联系客服。', :logo => "http://#{ImgDomian}/question_icon4%402x.png"},
                    {:question => '“可提现”金额里有10元，可以提现吗？', :answer => '请您继续赚取报酬，累计满100元即可提现。', :logo => "http://#{ImgDomian}/question_icon4%402x.png" }]

end
