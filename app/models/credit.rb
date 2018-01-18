class Credit < ActiveRecord::Base

	belongs_to :owner, :polymorphic => true 
	belongs_to :resource, :polymorphic => true 

	_METHODS = %w(recharge expend expire)

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

end

