class EWallet::KolPromotion < ActiveRecord::Base
  default_scope { where(state: true) }

  def get_kol_income_way
  	case self.income_way
    when 'money'
      return '现金'
    when 'puts'
      return 'PUTS'
  	else
  	  return ''
    end
  end
end
