class ContactMailWorker
	include Sidekiq::Worker

	def perform data , withdraw = false
		Rails.logger.sidekiq.info "#{self.class.to_s}: Start send contact email to #{data['email'] rescue nil}"
		begin
      if withdraw
        UserMailer.withdraw_apply(data).deliver if data.present?
      else
        UserMailer.contact_support(data).deliver if data.present?
      end
		rescue => e
			Rails.logger.sidekiq.error "Perform #{self.class.to_s} send email to #{data['email'] rescue nil} failed, error msg: #{e.message}"
			return
		end

		Rails.logger.sidekiq.info "Completed perform #{self.class.to_s}"
	end
end
