# 1积分 == 0.1元
class Credit < ActiveRecord::Base

	belongs_to :owner, polymorphic: true
	belongs_to :resource, polymorphic: true
								# 赠送     花费    过期   退还
	_METHODS = %w(recharge expend expire refund)

	validates_inclusion_of :_method, in: _METHODS

	def self.gen_record(_method, score, owner, resource=nil, expired_at=nil, remark=nil)
		self.create!(
			_method: 		_method,
			score: 			score,
			amount: 		owner.credit_amount + score,
			owner: 			owner,
			resource: 	resource,
			expired_at: expired_at,
			remark: 		remark
		)
	end

	def show_expired_at
		expired_at.strftime("%F %T")
	end

end

