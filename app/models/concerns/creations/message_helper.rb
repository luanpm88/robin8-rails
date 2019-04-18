module Creations
  module MessageHelper
    extend ActiveSupport::Concern

    def notice_to_brand(type='new_quote')
    	self.send(type)
    end

    def notice_to_app(type='new_creation')
      self.send(type)
    end

    def new_quote #新报价
      Message.new_quote_message(user, id)

      if user.email
        NewQuiteWorker.perform_async(user.email, "#{Rails.application.secrets[:vue_brand_domain]}/creations/#{id}/kols")
      elsif user.mobile_number
        YunPian::NewQuote.new(user.mobile_number).send_sms
      end
    end

    def uploaded_work #上传作品链接
      Message.uploaded_work_message(user, id)

      if user.email
        UploadedWorkWorker.perform_async(user.email, "#{Rails.application.secrets[:vue_brand_domain]}/creations/#{id}/kols")
      elsif user.mobile_number
        YunPian::UploadedWork.new(user.mobile_number).send_sms
      end
    end

    def new_creation
      Message.new_creation_message(self)
    end

    def paid_creation #brand确认合作,并且支付成功到robin8
      Message.paid_creation_message(self)
    end

    def approved_work #作品验收成功
      Message.approved_word_message(self)
    end

    def finished_creation #管理后台付款
      Message.finished_creation_message(self)
    end

    
  end
end