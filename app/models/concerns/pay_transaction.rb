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
          self.increment!(:frozen_amount, credits)
          transaction = build_transaction(credits, subject, 'frozen', item , opposite)
          transaction.save
        end
      end
    end

    #解冻结资金
    #credits: 金额， subject: 事项主题 ， item :事项对象， opposite: 关联方对象
    def unfrozen(credits,  subject, item = nil, opposite = nil)
      return raise "解冻的金额超过冻结金额 credits:#{credits}  frozen_amount:#{frozen_amount}" if credits.to_f  > frozen_amount.to_f
      ActiveRecord::Base.transaction do
        self.decrement!(:frozen_amount, credits)
        transaction = build_transaction(credits, subject, 'unfrozen', item , opposite)
        transaction.save
      end
    end

    def income(credits,  subject, item = nil, opposite = nil)
      ActiveRecord::Base.transaction do
        self.increment!(:amount, credits)
        transaction = build_transaction(credits, subject, 'income', item , opposite)
        transaction.save
      end
    end

    def payout(credits,  subject, item = nil, opposite = nil)
      ActiveRecord::Base.transaction do
        self.decrement!(:amount, credits)
        transaction = build_transaction(credits, subject, 'payout', item , opposite)
        transaction.save
      end
    end

    def build_transaction(credits,  subject, direct, item = nil, opposite = nil)
      self.transactions.build(:credits => credits, :account => self, :subject => subject, :direct => direct,
                      :item => item, :opposite => opposite, :amount => self.amount, :frozen_amount => self.frozen_amount,
                      :avail_amount => self.avail_amount)
    end
  end
end
