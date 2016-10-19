module Concerns
  module PayTransaction
    extend ActiveSupport::Concern
    included do
      has_many :transactions, :as => :account
    end

    def avail_amount
      self.amount  - self.frozen_amount
    end

    def can_pay?(credits)
      if self.avail_amount  < credits
        raise '账户余额不足'
      else
        return true
      end
    end


    #冻结资金
    #credits: 金额， subject: 事项主题 ， item :事项对象， opposite: 关联方对象
    def frozen(credits,  subject, item = nil, opposite = nil)
      if can_pay?(credits)
        ActiveRecord::Base.transaction do
          self.lock!
          self.increment!(:frozen_amount, credits)
          transaction = build_transaction(credits, subject, 'frozen', item , opposite)
          transaction.save!
        end
      end
    end

    #解冻结资金
    #credits: 金额， subject: 事项主题 ， item :事项对象， opposite: 关联方对象
    def unfrozen(credits,  subject, item = nil, opposite = nil)
      return raise "解冻的金额超过冻结金额 credits:#{credits}  frozen_amount:#{frozen_amount}" if credits.to_f  > frozen_amount.to_f
      ActiveRecord::Base.transaction do
        self.lock!
        self.decrement!(:frozen_amount, credits)
        transaction = build_transaction(credits, subject, 'unfrozen', item , opposite)
        transaction.save!
      end
    end

    def income(credits,  subject, item = nil, opposite = nil, created_at = nil)
      ActiveRecord::Base.transaction do
        self.lock!
        self.increment!(:amount, credits)
         # only count net income if need
        self.increment!(:historical_income, (self.get_income_of(item) || credits)) if self.is_a? Kol and Transaction::KOL_INCOME_SUBJECTS.include?(subject)
        self.increment!(:historical_recharge, credits) if self.is_a? User and Transaction::RECHARGE_SUBJECTS.include?(subject)
        self.decrement!(:historical_payout, credits)   if self.is_a? User and Transaction::USER_CAMPAIGN_INCOME_SUBJECTS.include?(subject)
        transaction = build_transaction(credits, subject, 'income', item , opposite, created_at)
        transaction.save!
        transaction
      end
    end

    def payout(credits,  subject, item = nil, opposite = nil)
      ActiveRecord::Base.transaction do
        self.lock!
        if item.present? && item.is_a?(Campaign)
          if item.status != 'unpay'
            Rails.logger.transaction.info "-------- 重复支付: #{item.inspect} -----------}"
            raise Exception.new("\n重复支付: #{item.inspect}\n")
          end
        end
        self.decrement!(:amount, credits)
        self.increment!(:historical_payout, credits) if self.is_a? User and Transaction::USER_CAMPAIGN_PAYOUT_SUBJECTS.include?(subject)
        transaction = build_transaction(credits, subject, 'payout', item , opposite)
        transaction.save!
      end
    end

    def payout_by_alipay(credits, subject, item, opposite=nil)
      ActiveRecord::Base.transaction do
        self.lock!
        self.increment!(:historical_recharge, credits) if self.is_a? User and Transaction::RECHARGE_SUBJECTS.include?(subject)
        self.increment!(:historical_payout, credits) if self.is_a? User and Transaction::USER_CAMPAIGN_PAYOUT_SUBJECTS.include?(subject)
        transaction = build_transaction(credits, subject, 'payout', item , opposite)
        transaction.save!
      end
    end

    def build_transaction(credits,  subject, direct, item = nil, opposite = nil, created_at = Time.now)
      self.transactions.build(:credits => credits, :account => self, :subject => subject, :direct => direct,
                      :item => item, :opposite => opposite, :amount => self.amount, :frozen_amount => self.frozen_amount,
                      :avail_amount => self.avail_amount, :created_at => created_at)
    end
  end
end
