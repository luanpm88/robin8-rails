class EWallet::Promotion < ActiveRecord::Base
  default_scope { where(state: true) }

  def get_promotion_way
    case self.promotion_way
    when 'rebate'
      return '回扣'
    when 'enlarge'
      return '放大'
    end
  end
end
