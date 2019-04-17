module Creations
  module MessageHelper
    extend ActiveSupport::Concern

    def notice_to_brand(type='new_quote')
    	self.send(type)
    end

    def notice_to_app
      
    end

    def new_quote
      Message.new_quote_message(user, id)

      if user.email
        NewQuiteWorker.perform_async(user.email, "#{Rails.application.secrets[:vue_brand_domain]}/creations/#{id}/kols")
      elsif user.mobile_number
        YunPian::NewQuote.new(user.mobile_number).send_sms
      end
    end
    
  end
end