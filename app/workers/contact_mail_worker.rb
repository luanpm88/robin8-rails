class ContactMailWorker
	include Sidekiq::Worker

	def perform data
		Rails.logger.sidekiq.info "#{self.class.to_s}: Start send contact email to #{data['email']}"
		begin 
			UserMailer.contact_support(data).deliver if data.present?
		rescue => e
			Rails.logger.sidekiq.error "Perform #{self.class.to_s} send email to #{data['email']} failed, error msg: #{e.message}"
			return
		end

		Rails.logger.sidekiq.info "Completed perform #{self.class.to_s}"
	end
end