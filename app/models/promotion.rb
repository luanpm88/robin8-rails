class Promotion < ActiveRecord::Base

	def to_ary
		[id, title, min_credit, rate, start_at.to_s(:utc), end_at.to_s(:utc), state ? '是' : '否']
	end

	def self.valid
		self.where("state=? and start_at<=? and end_at >=?", true, Time.now, Time.now).order(updated_at: :desc).first
	end

  def to_hash
    attributes.merge(expired_at: Time.now.since(valid_days_count.days).strftime("%F %T"))
  end

end
